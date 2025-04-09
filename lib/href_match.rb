module JekyllSupport
  class HRefTag
    private

    def compute_link_and_text
      page_matches = @site.everything # ? all_documents ?
                          .select { |page| page.url&.include? @path }
                          .reject { |x| x.path == 'redirect.html' } || []
      case page_matches.length
      when 0
        msg = "HRef error: No url matches '#{@path}', found on line #{@line_number} (after front matter) of #{@path}"
        @logger.error { msg }
        abort msg if @die_if_nomatch

        @text = "<i class='not_public_yet'><code>#{@path}</code> is not a public page yet</i>"
        @link_save = @link = '#'
      when 1
        @link = page_matches.first.url
        @link = "#{@link}##{@fragment}" if @fragment
        @link_save = @link
        @text = page_matches.first.title unless @label
      else
        logger.error { "Error: More than one url matched '#{@path}', referenced in '#{@page['path']}':\n  #{page_matches.map(&:url).join("\n  ")}" }
        exit! 2
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

      compute_link_and_text
    end
  end
end
