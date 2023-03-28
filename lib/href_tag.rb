require 'jekyll_all_collections'
require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'
require 'liquid'
require_relative 'jekyll_href/version'
require_relative 'hash_array'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
# Generates an href.

module HrefTag
  # Implements href Jekyll tag
  class HrefTag < JekyllSupport::JekyllTag # rubocop:disable Metrics/ClassLength
    attr_reader :follow, :helper, :line_number, :match, :page, :path, :site, :summary,
                :summary_exclude,:summary_href, :target, :text, :url
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
      linkk = compute_linkk
      linkk = replace_vars(linkk)
      linkk.delete_prefix('./') # normalize relative links
      @link_save = linkk
      @helper_save = @helper.clone
      globals_update(@helper.argv, linkk) # Sets @link and @text, might clear @follow and @target
      handle_match if @match
      save_summary
      "<a href='#{@link}'#{@target}#{@follow}>#{@text}</a>"
    end

    private

    def save_summary
      return if @summary_exclude || @link.start_with?('mailto:')

      @summary ||= @text
      @summary_href = "<a href='#{@link}'#{@target}#{@follow}>#{@summary}</a>"
      if @link.start_with?('http')
        add_global_link_for_page self
      elsif !@link.start_with?('#')
        add_local_link_for_page self
      end
    end

    # Does not look at or compute @link
    def compute_linkk
      return @link if @link

      linkk = @url
      if linkk.nil? || !linkk
        linkk = @helper.argv&.shift
        @helper.params&.shift
        @helper.keys_values&.delete(linkk)
        dump_linkk_relations(linkk) if linkk.nil?
      elsif @url.to_s.empty?
        dump_linkk_relations(linkk)
      end
      linkk
    end

    def dump_linkk_relations(linkk)
      msg = <<~END_MESSAGE
        jekyll_href error: no url was provided on #{@path}:#{@line_number}.
          @helper.markup=#{@helper.markup}
          @helper.argv='#{@helper.argv}'
          linkk='#{linkk}'
          @match='#{@match}'
          @url='#{@url}'
          @follow='#{@follow}
          @target='#{@target}'
      END_MESSAGE
      abort msg.red
    end

    # Sets @follow, @helper, @match, @path, @shy, @target, @url, @wbr
    def globals_initial
      @path = @page['path']
      AllCollectionsHooks.compute(@site)

      @follow          = @helper.parameter_specified?('follow') ? '' : " rel='nofollow'"
      @match           = @helper.parameter_specified? 'match'
      @blank           = @helper.parameter_specified? 'blank'
      @summary_exclude = @helper.parameter_specified? 'summary_exclude'
      @shy             = @helper.parameter_specified? 'shy'
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
        @text = tokens.join(' ').strip
        if @text.to_s.empty?
          text = linkk
          text = linkk.gsub('/', '/&shy;') if @shy
          text = linkk.gsub('/', '/<wbr>') if @wbr
          @text = "<code>#{text}</code>"
          @link = "https://#{linkk}"
        else
          @link = if @shy
                    linkk.gsub('/', '/&shy;')
                  elsif @wbr
                    linkk.gsub('/', '/<wbr>')
                  else
                    linkk
                  end
        end
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
        @link = '#'
        @text = "<i>#{@link} is not available</i>"
      when 1
        @link = url_matches.first
        @link = "#{@link}##{@fragment}" if @fragment
      else
        abort "Error: More than one url matched '#{@path}': #{url_matches.join(', ')}"
      end
    end

    # Replace names in plugin-vars with values
    def replace_vars(text)
      variables = @site.config['plugin-vars']
      return text unless variables

      variables.each do |name, value|
        text = text.gsub "{{#{name}}}", value
      end
      @logger.debug { "@link=#{@link}" }
      text
    end

    JekyllPluginHelper.register(self, 'href')
  end
end
