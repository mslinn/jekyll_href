module MSlinn
  class HRefTag
    private

    def compute_link_and_text(all_urls)
      url_matches = all_urls.select { |url| url&.include? @path }
      case url_matches.length
      when 0
        abort "href error: No url matches '#{@link}', found on line #{@line_number} (after front matter) of #{@path}" if @die_if_nomatch
        @link_save = @link = '#'
        @text = "<i>#{@link} is not available</i>"
      when 1
        @link = url_matches.first
        @link = "#{@link}##{@fragment}" if @fragment
        @link_save = @link
      else
        abort "Error: More than one url matched '#{@path}': #{url_matches.join(', ')}"
      end
    end

    def handle_match(link)
      @follow = ''
      @target = '' unless @blank
      @path, @fragment = link.split('#')

      @logger.debug do
        <<~END_DEBUG
          @link=#{@link}
          @site.posts.docs[0].url  = #{@site.posts.docs[0].url}
          @site.posts.docs[0].path = #{@site.posts.docs[0].path}
        END_DEBUG
      end

      all_urls = @site.all_collections.map(&:url)
      compute_link_and_text(all_urls)
    end
  end
end
