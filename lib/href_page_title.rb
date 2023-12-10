module HrefTag
  class HrefTag
    private

    @hrefs = {}

    def find_page(path)
      all_pages = @site.all_collections + @site.pages
      pages = if @match
                all_pages.select { |page| page.url&.include? path }
              elsif @label_source == :from_page_title
                all_pages.select { |page| page.url == path }
              end
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
        @text = "<div class='href_error'>Error: #{msg}</div><pre>{% href #{@argument_string}%}</pre>"
        raise HRefError, msg
      end
      @text = @label = page.title
    rescue HRefError => e
      @text ||= "<div class='href_error'>Error: href tags with page_title require local links</div><pre>{% href #{@argument_string}%}</pre>"
      @link = linkk

      e.shorten_backtrace
      msg = format_error_message e.message
      @logger.error "#{e.class} raised #{msg}"
      raise e if @die_on_href_error

      "<div class='href_error'>#{e.class} raised in #{self.class};\n#{msg}</div>"
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
