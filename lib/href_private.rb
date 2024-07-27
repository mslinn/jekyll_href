module JekyllSupport
  class HRefTag
    private

    # Does not look at or compute @link
    def compute_linkk
      return @link, nil if @link

      linkk = @url
      if linkk.nil? || !linkk
        linkk = @helper.argv&.shift
        @helper.params&.shift
        @helper.keys_values&.delete linkk
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
        No URL was provided on #{@path}:#{@line_number} (after front matter).
          <pre>{% href #{@argument_string.strip} %}</pre>
      END_MESSAGE
      @logger.error { JekyllSupport::JekyllPluginHelper.remove_html_tags msg.strip }
      "<div class='href_error'>HRefError: #{msg}</div>"
    end

    # Sets @follow, @helper, @match, @path, @target, @url, @hyphenation
    def globals_initial
      @path = @page['path']
      AllCollectionsHooks.compute @site
      @hyphenation      = Hyphenation::NONE

      @blank            = @helper.parameter_specified? 'blank'
      @klass            = @helper.parameter_specified? 'class'
      @follow_specified = @helper.parameter_specified?('follow')
      @follow           = @follow_specified ? '' : ' rel="nofollow"'
      @label            = @helper.parameter_specified? 'label'
      @match            = @helper.parameter_specified? 'match'
      @hyphenation      = Hyphenation::SHY if @helper.parameter_specified? 'shy'
      @style            = @helper.parameter_specified? 'style'
      @summary          = @helper.parameter_specified? 'summary'
      @summary_exclude  = @helper.parameter_specified? 'summary_exclude'
      @target           = @blank ? " target='_blank'" : nil
      @target         ||= @helper.parameter_specified?('notarget') ? '' : " target='_blank'"
      @url              = @helper.parameter_specified? 'url'

      if @helper.parameter_specified? 'wbr' # <wbr> has precedence over &shy;
        if @hyphenation == Hyphenation::SHY
          @logger.info do
            "Warning: wbr and shy were both specified for the href tag on line #{@line_number} (after front matter) of #{@page['path']}"
          end
        end
        @hyphenation = Hyphenation::WBR
      end

      @label_source = if @helper.parameter_specified? 'page_title'
                        LabelSource::FROM_PAGE_TITLE
                      elsif @label
                        LabelSource::FROM_EXPLICIT_LABEL
                      else
                        LabelSource::FROM_IMPLICIT_LABEL
                      end

      return unless @tag_config

      @die_on_href_error = @tag_config['die_on_href_error'] == true
      @die_on_nomatch    = @tag_config['die_on_nomatch']    == true
      @pry_on_href_error = @tag_config['pry_on_href_error'] == true
    end

    # Sets @link_type
    # Might set @follow, @link, @link_save and @text
    def globals_update(tokens, linkk)
      @link_type = LinkType::UNKNOWN

      if linkk.start_with? 'mailto:'
        handle_mailto linkk
        return
      end

      @link_type = if linkk.start_with? 'http'
                     LinkType::EXTERNAL
                   elsif linkk.start_with? '#'
                     LinkType::FRAGMENT
                   else
                     LinkType::LOCAL
                   end

      @follow = !@follow_specified && @link_type == LinkType::EXTERNAL ? ' rel="nofollow"' : ''

      handle_page_title linkk if @label_source == LabelSource::FROM_PAGE_TITLE
      @text = @label || tokens.join(' ').strip
      @link = if @text.to_s.empty?
                handle_empty_text linkk
              else
                linkk
              end
      @link_save = @link
      return if @link_type == LinkType::EXTERNAL

      @follow = ''
      @target = '' unless @blank
      nil
    end

    # Sets @text and @link
    def handle_empty_text(linkk)
      text = hyphenate linkk
      @text = "<code>#{text}</code>"
      @link = if linkk.start_with? '#'
                linkk
              elsif insecure_ip_address linkk
                "http://#{linkk}"
              else
                "https://#{linkk}"
              end
    end

    def handle_mailto(linkk)
      @link_type = LinkType::MAILTO
      @link = linkk
      @target = @follow = ''
      @text = @label || @helper.argv.join(' ')
      return unless @text.empty?

      text = hyphenate(linkk.delete_prefix('mailto:'))
      @text = "<code>#{text}</code>"
    end

    def hyphenate(linkk)
      if @hyphenation == Hyphenation::WBR
        linkk&.gsub('/', '/<wbr>')
      elsif @hyphenation == Hyphenation::SHY
        linkk&.gsub('/', '/&shy;')
      else
        linkk
      end
    end

    def insecure_ip_address(string)
      return true if string.start_with?('localhost', 'http://localhost')

      return false unless IPAddress.valid? string

      ip_address = IPAddress string
      true if ip_address.loopback? || ip_address.private?
    ensure
      false
    end
  end
end
