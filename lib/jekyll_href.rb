# frozen_string_literal: true

require "jekyll_plugin_logger"
require "jekyll_all_collections"
require "liquid"
require_relative "jekyll_href/version"
require_relative './jekyll_tag_helper2'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
# Generates an href.
class ExternalHref < Liquid::Tag
  # @param tag_name [String] is the name of the tag, which we already know.
  # @param markup [String] the arguments from the web page.
  # @param _tokens [Liquid::ParseContext] tokenized command line
  #        By default it has two keys: :locale and :line_numbers, the first is a Liquid::I18n object, and the second,
  #        a boolean parameter that determines if error messages should display the line number the error occurred.
  #        This argument is used mostly to display localized error messages on Liquid built-in Tags and Filters.
  #        See https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-tags
  # @return [void]
  def initialize(tag_name, markup, _tokens)
    super
    markup = '' if markup.nil?
    markup.strip!

    @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    @helper = JekyllTagHelper2.new(tag_name, markup, @logger)
  end

  # Method prescribed by the Jekyll plugin lifecycle.
  # @param liquid_context [Liquid::Context]
  # @return [String]
  def render(liquid_context) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    _content = super
    @helper.liquid_context = liquid_context

    @site = liquid_context.registers[:site]
    JekyllAllCollections.maybe_compute_all_collections(@site)

    @match = @helper.parameter_specified?('match')
    @url   = @helper.parameter_specified?('url')

    link = @url || @helper.argv.shift

    finalize(@helper.argv, link) # Sets @link and @text, might clear @follow and @target
    @link = replace_vars(liquid_context, @link)

    if @match
      match(liquid_context)
      @follow = ''
      @target = ''
    else
      @follow = @helper.parameter_specified?('follow') ?   '' : " rel='nofollow'"
      @target = @helper.parameter_specified?('notarget') ? '' : " target='_blank'"
    end

    @logger.debug { "@link=#{@link}" }
    "<a href='#{@link}'#{@target}#{@follow}>#{@text}</a>"
  end

  private

  def finalize(tokens, link) # rubocop:disable Metrics/MethodLength
    if link.start_with? 'mailto:'
      @link = link
      @target = @follow = ''
      @text = link.delete_prefix 'mailto:'
      return
    else
      @text = tokens.join(" ").strip
      if @text.empty?
        @text = "<code>#{link}</code>"
        @link = "https://#{link}"
      else
        @link = link
      end
    end

    return if @link.start_with? "http"

    @follow = ''
    @target = ''
  end

  def match(_liquid_context) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    # Might set @link and @text
    config = @site.config['href']
    die_if_nomatch = !config.nil? && config['nomatch'] && config['nomatch'] == 'fatal'

    if @link.nil?
      puts "@link is nil"
    end
    path, fragment = @link.split('#')

    @logger.debug do
      <<~END_DEBUG
        @link=#{@link}
        @site.posts.docs[0].url  = #{@site.posts.docs[0].url}
        @site.posts.docs[0].path = #{@site.posts.docs[0].path}
      END_DEBUG
    end

    all_urls = @site.all_collections.map(&:url)
    url_matches = all_urls.select { |url| url.include? path }
    case url_matches.length
    when 0
      abort "href error: No url matches '#{@link}'" if die_if_nomatch
      @link = "#"
      @text = "<i>#{@link} is not available</i>"
    when 1
      @link = url_matches.first
      @link = "#{@link}\##{fragment}" if fragment
    else
      abort "Error: More than one url matched '#{path}': #{url_matches.join(", ")}"
    end
  end

  def replace_vars(_liquid_context, link)
    variables = @site.config['plugin-vars']
    return link unless variables

    variables.each do |name, value|
      link = link.gsub "{{#{name}}}", value
    end
    link
  end
end

PluginMetaLogger.instance.info { "Loaded jeykll_href v#{JekyllHrefVersion::VERSION} plugin." }
Liquid::Template.register_tag('href', ExternalHref)
