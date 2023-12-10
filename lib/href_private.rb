module HrefTag
  class HrefTag
    private

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
    rescue HRefError => e
      [nil, e]
    end

    def error_no_uri
      msg = <<~END_MESSAGE
        Error: no url was provided on #{@path}:#{@line_number} (after front matter).
          <pre>{% href #{@argument_string}%}</pre>
      END_MESSAGE
      @logger.error { Sanitize.fragment msg }
      "<div class='href_error'>#{msg}</div>"
    end

    # Sets @follow, @helper, @match, @path, @shy, @target, @url, @wbr
    def globals_initial
      @path = @page['path']
      AllCollectionsHooks.compute(@site)

      @blank           = @helper.parameter_specified? 'blank'
      @klass           = @helper.parameter_specified? 'class'
      @follow          = @helper.parameter_specified?('follow') ? '' : " rel='nofollow'"
      @label           = @helper.parameter_specified? 'label'
      @match           = @helper.parameter_specified? 'match'
      @shy             = @helper.parameter_specified? 'shy'
      @style           = @helper.parameter_specified? 'style'
      @summary         = @helper.parameter_specified? 'summary'
      @summary_exclude = @helper.parameter_specified? 'summary_exclude'
      @target          = @blank ? " target='_blank'" : nil
      @target        ||= @helper.parameter_specified?('notarget') ? '' : " target='_blank'"
      @url             = @helper.parameter_specified? 'url'
      @wbr             = @helper.parameter_specified? 'wbr'

      @label_source    = if @helper.parameter_specified? 'page_title'
                           :from_page_title
                         elsif @label
                           :from_explicit_label
                         else
                           :from_implicit_label
                         end

      return unless @tag_config

      @die_on_href_error = @tag_config['die_on_href_error'] == true
    end

    # Might set @external_link, @follow, @local_link, @linkk, @target, and @text
    def globals_update(tokens, linkk)
      if linkk.start_with? 'mailto:'
        handle_mailto linkk
        return
      else
        if @label_source == :from_page_title
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

    def insecure_ip_address(string)
      return true if string.start_with? 'localhost'

      return false unless IPAddress.valid? string

      ip_address = IPAddress string
      true if ip_address.loopback? || ip_address.private?
    ensure
      false
    end
  end
end
