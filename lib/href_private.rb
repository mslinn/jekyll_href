module HrefTag
  class HrefTag # rubocop:disable Metrics/ClassLength
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

    # Does not look at or compute @link
    def compute_linkk
      return @link, nil if @link

      linkk = @url
      if linkk.nil? || !linkk
        linkk = @helper.argv&.shift
        @helper.params&.shift
        @helper.keys_values&.delete(linkk)
        return nil, error_no_uri if linkk.nil?
      elsif @url.to_s.empty?
        return nil, error_no_uri
      end
      [linkk, nil]
    end

    def error_no_uri
      msg = <<~END_MESSAGE
        Error: no url was provided on #{@path}:#{@line_number} (after front matter).
          <pre>{% href #{@argument_string}%}</pre>
      END_MESSAGE
      @logger.error { Sanitize.fragment msg }
      "<span class='error'>#{msg}</span>"
    end

    # Sets @follow, @helper, @match, @path, @shy, @target, @url, @wbr
    def globals_initial
      @path = @page['path']
      AllCollectionsHooks.compute(@site)

      @page_title = @helper.parameter_specified? 'page_title'
      @blank           = @helper.parameter_specified? 'blank'
      @klass           = @helper.parameter_specified? 'class'
      @follow          = @helper.parameter_specified?('follow') ? '' : " rel='nofollow'"
      @match           = @helper.parameter_specified? 'match'
      @label           = @helper.parameter_specified? 'label'
      @summary_exclude = @helper.parameter_specified? 'summary_exclude'
      @shy             = @helper.parameter_specified? 'shy'
      @style           = @helper.parameter_specified? 'style'
      @summary         = @helper.parameter_specified? 'summary'
      @target          = @blank ? " target='_blank'" : nil
      @target        ||= @helper.parameter_specified?('notarget') ? '' : " target='_blank'"
      @url             = @helper.parameter_specified? 'url'
      @wbr             = @helper.parameter_specified? 'wbr'

      return unless @tag_config

      @die_on_href_error = @tag_config['die_on_href_error'] == true
    end

    # Might set @external_link, @follow, @local_link, @linkk, @target, and @text
    def globals_update(tokens, linkk)
      if linkk.start_with? 'mailto:'
        handle_mailto linkk
        return
      else
        if @page_title
          handle_page_title linkk
          return
        end
        @text = @label || tokens.join(' ').strip
        if @text.to_s.empty?
          handle_empty_text linkk
        else
          handle_text linkk
        end
        @link_save = @link
      end

      if @external_link
        @target = ''
        return
      end
      @follow = ''
      @target = '' unless @blank
    end

    def handle_page_title(linkk)
      raise HRefError, 'page_titled href tags require local links.' unless @local_link

      @label = @page.title
      @follow = @target = ''
    rescue HRefError => e
      @label = "<span class='error'>page_titled href tags require local links</span>"
      @link = linkk

      e.shorten_backtrace
      msg = format_error_message e.message
      @logger.error "#{e.class} raised #{msg}"
      raise e if @die_on_href_error

      "<div class='custom_error'>#{e.class} raised in #{self.class};\n#{msg}</div>"
    ensure
      if @text.to_s.empty?
        handle_empty_text linkk
      else
        handle_text linkk
      end
      nil
    end

    def handle_match
      match_post
      @follow = ''
      @target = '' unless @blank
    end

    def handle_empty_text(linkk)
      text = linkk
      text = linkk&.gsub('/', '/&shy;') if @shy
      text = linkk&.gsub('/', '/<wbr>') if @wbr
      @text = "<code>#{text}</code>"
      @external_link = linkk.start_with? 'http'
      @local_link = !@external_link
      @mailto_link = false
      @link = if @external_link
                linkk
              elsif insecure_ip_address linkk
                "http://#{linkk}"
              else
                "https://#{linkk}"
              end
    end

    def handle_mailto(linkk)
      @mailto_link = true
      @local_link = @external_link = false
      @link = linkk
      @target = @follow = ''
      @text = @helper.argv.join(' ')
      return unless @text.empty?

      text = linkk.delete_prefix('mailto:')
      @text = "<code>#{text}</code>"
    end

    def handle_text(linkk)
      @link = if @shy
                linkk&.gsub('/', '/&shy;')
              elsif @wbr
                linkk&.gsub('/', '/<wbr>')
              else
                linkk
              end
    end

    # Might set @link and @text
    def match_post
      config = @site.config['href']
      @die_if_nomatch = !config.nil? && config['nomatch'] && config['nomatch'] == 'fatal'
      @path, @fragment = @link.split('#')

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

    def insecure_ip_address(string)
      return true if string.start_with? 'localhost'

      return false unless IPAddress.valid? string

      ip_address = IPAddress string
      true if ip_address.loopback? || ip_address.private?
    rescue StandardError
      false
    ensure
      false
    end

    def save_summary
      return if @summary_exclude || @link_save.start_with?('mailto:') || @link_save.start_with?('#')

      @summary = @summary.to_s.empty? ? @text : @summary.to_s
      if @summary == true
        warning = <<~END_WARNING
          Warning: a href plugin keyword option was detected in the link text for #{@path} on line #{line_number}.
          The href tag will not be included in the summary, and the link text will not have the word summary included.
          This is probably unintentional. Consider using the label option to correct this problem."
        END_WARNING
        puts warning.red
        return
      end
      return if @summary.class != String || @summary.empty?

      @summary = @summary[0].upcase + @summary[1..]
      @summary_href = "<a href='#{@link_save}'#{@target}#{@follow}>#{@summary}</a>"
      mini_href = MiniHref.new(
        follow:          @follow,
        html:            @summary_href,
        line_number:     @line_number,
        link:            @link_save,
        link_save:       @link_save,
        path:            @path,
        summary_exclude: @summary_exclude,
        summary_href:    @summary_href
      )
      if @link_save.start_with? 'http'
        add_global_link_for_page mini_href
      else
        add_local_link_for_page mini_href
      end
    end
  end
end
