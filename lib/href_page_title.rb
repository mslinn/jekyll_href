module HrefTag
  class HrefTag
    private

    @hrefs = {}

    def find_page(path)
      all_pages = @site.all_collections + @site.pages
      pages = all_pages.select { |page| page.url == path }
      pages&.first
    end

    def handle_page_title(linkk)
      @follow = @target = ''
      @external_link = linkk.start_with? 'http'
      @local_link = !@external_link
      raise HRefError, 'href tags with page_title require local links.' unless @local_link

      page = find_page linkk
      unless page
        msg = "There is no page at path #{linkk}"
        @text = "<span class='error'>Error: #{msg}</span><pre>{% href #{@argument_string}%}</pre>"
        raise HRefError, msg
      end
      @text = @label = page.title
    rescue HRefError => e
      @text ||= "<span class='error'>Error: href tags with page_title require local links</span><pre>{% href #{@argument_string}%}</pre>"
      @link = linkk
      raise e if @die_on_href_error
    ensure
      if @text.to_s.empty?
        handle_empty_text linkk
      else
        handle_text linkk
      end
      @label
    end
  end
end
