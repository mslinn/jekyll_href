module JekyllSupport
  class HRefTag
    private

    @hrefs = {}

    def find_page(path)
      all_pages = @site.all_collections + @site.pages
      pages = if @match
                all_pages.select { |page| page.url&.include? path }
              elsif @label_source == LabelSource::FROM_PAGE_TITLE
                all_pages.select { |page| page.url == path }
              end
      pages&.first
    end

    # Handles links to Jekyll pages
    # Uses the linked page title as the link text
    def handle_page_title(linkk)
      @follow = @target = ''
      unless @link_type == LinkType::LOCAL
        puts 'Oops'
        raise HrefError, 'href tags with page_title require local links.'
      end

      page = find_page linkk
      unless page
        msg = "There is no page at path #{linkk}"
        @text = "<div class='href_error'>HrefError: #{msg}</div>\n<pre>  {% href #{@argument_string.strip} %}</pre>"
        raise HrefError, msg
      end
      @text = @label = page.title
      handle_empty_text linkk if @text.to_s.empty?
      @label
    end
  end
end
