require 'ipaddress'
require 'jekyll_all_collections'
require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'
require 'liquid'
require 'sanitize'
require_relative 'jekyll_href/version'
require_relative 'hash_array'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
# Generates an href.

module HrefTag
  MiniHref = Struct.new(:follow, :html, :link, :line_number, :link_save, :path, :summary_exclude, :summary_href, keyword_init: true)

  # Implements href Jekyll tag
  class HrefTag < JekyllSupport::JekyllTag # rubocop:disable Metrics/ClassLength
    attr_reader :follow, :helper, :line_number, :link_save, :match, :page, :path, :site,
                :summary, :summary_exclude, :summary_href, :target, :text, :url
    attr_accessor :link

    include JekyllHrefVersion
    include HashArray
    include Comparable

    def <=>(other)
      return nil unless other.is_a?(self.class)

      [follow, match, path, target, text] <=> [other.follow, other.match, other.path, other.target, other.text]
    end

    def to_s
      "On line #{line_number} of #{path}: #{follow} #{match} #{target} #{link} => '#{text}'"
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # @param liquid_context [Liquid::Context]
    # @return [String]
    def render_impl
      globals_initial
      linkk, error_msg = compute_linkk
      return error_msg unless linkk

      linkk = replace_vars(linkk)
      linkk.delete_prefix('./') # normalize relative links
      @url = linkk if @url
      @link_save = linkk
      @helper_save = @helper.clone
      globals_update(@helper.argv, linkk) # Sets @link and @text, might clear @follow and @target
      handle_match if @match
      save_summary
      klass = " class='#{@klass}'" if @klass
      style = " style='#{@style}'" if @style
      "<a href='#{@link}'#{klass}#{style}#{@target}#{@follow}>#{@text}</a>"
    end

    private

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
      "<span class='error'>Error: #{msg}</span>"
    end

    # Sets @follow, @helper, @match, @path, @shy, @target, @url, @wbr
    def globals_initial
      @path = @page['path']
      AllCollectionsHooks.compute(@site)

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
    end

    # Might set @follow, @linkk, @target, and @text
    def globals_update(tokens, linkk)
      if linkk.start_with? 'mailto:'
        @link = linkk
        @target = @follow = ''
        @text = @helper.argv.join(' ')
        if @text.empty?
          text = linkk.delete_prefix('mailto:')
          @text = "<code>#{text}</code>"
        end
        return
      else
        @text = @label || tokens.join(' ').strip
        if @text.to_s.empty?
          text = linkk
          text = linkk.gsub('/', '/&shy;') if @shy
          text = linkk.gsub('/', '/<wbr>') if @wbr
          @text = "<code>#{text}</code>"
          @link = if linkk.start_with?('http')
                    linkk
                  elsif insecure_ip_address linkk
                    "http://#{linkk}"
                  else
                    "https://#{linkk}"
                  end
        else
          @link = if @shy
                    linkk.gsub('/', '/&shy;')
                  elsif @wbr
                    linkk.gsub('/', '/<wbr>')
                  else
                    linkk
                  end
        end
        @link_save = @link
      end

      return if @link.start_with? 'http'

      @follow = ''
      @target = '' unless @blank
    end

    def handle_match
      match_post
      @follow = ''
      @target = '' unless @blank
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

    def compute_link_and_text(all_urls)
      url_matches = all_urls.select { |url| url&.include? @path }
      case url_matches.length
      when 0
        abort "href error: No url matches '#{@link}'" if @die_if_nomatch
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

    def insecure_ip_address(string)
      return true if string.start_with? 'localhost'

      return false unless IPAddress.valid? string

      ip_address = IPAddress string
      return true if ip_address.loopback? || ip_address.private?
    rescue StandardError
      false
    ensure
      false
    end

    # Replace names in plugin-vars with values
    def replace_vars(text)
      variables = @site.config['plugin-vars']
      return text unless variables

      variables.each do |name, value|
        text = text.gsub "{{#{name}}}", value
      end
      text
    end

    JekyllPluginHelper.register(self, 'href')
  end
end
