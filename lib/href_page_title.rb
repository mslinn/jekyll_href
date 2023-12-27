module MSlinn
  class HRefTag
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
        @text = "<div class='href_error'>HRefError: #{msg}</div>\n<pre>  {% href #{@argument_string.strip} %}</pre>"
        raise HRefError, msg
      end
      @text = @label = page.title
    rescue HRefError => e
      msg = format_error_message "#{e.message}\n<pre>  {% href #{@argument_string.strip} %}</pre>"
      @text = "<div class='href_error'>#{msg}</div>"
      @link = linkk

      e.shorten_backtrace
      @logger.error { "#{e.class} raised #{JekyllPluginHelper.remove_html_tags msg}" }
      raise e if @die_on_href_error

      "<div class='href_error'>HRefError raised in #{self.class};\n#{msg}</div>"
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
