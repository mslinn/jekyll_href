# frozen_string_literal: true

require "jekyll_plugin_logger"
require "jekyll_all_collections"
require "liquid"
require_relative "jekyll_href/version"
require_relative './jekyll_tag_helper2'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
#
# Generates an href.
# Note that the url should not be enclosed in quotes.
#
# If the link starts with 'http' or `match` is specified:
#   The link will open in a new tab or window
#   The link will include `rel=nofollow` for SEO purposes.
#
# To suppress the `nofollow` attribute, preface the link with the word `follow`.
# To suppress the `target` attribute, preface the link with the word `notarget`.
#
# The `match` option looks through the pages collection for a URL with containing the provided substring.
# Match implies follow and notarget.
#
# If a section called plugin-vars exists then its name/value pairs are available for substitution.
#   plugin-vars:
#     django-github: 'https://github.com/django/django/blob/3.1.7'
#     django-oscar-github: 'https://github.com/django-oscar/django-oscar/blob/3.0.2'
#
#
# @example General form
#   {% href [follow] [notarget] [match] url text to display %}
#
# @example Generates `nofollow` and `target` attributes.
#   {% href https://mslinn.com The Awesome %}
#
# @example Does not generate `nofollow` or `target` attributes.
#   {% href follow notarget https://mslinn.com The Awesome %}
#
# @example Does not generate `nofollow` attribute.
#   {% href follow https://mslinn.com The Awesome %}
#
# @example Does not generate `target` attribute.
#   {% href notarget https://mslinn.com The Awesome %}
#
# @example Matches page with URL containing abc.
#   {% href match abc The Awesome %}
# @example Matches page with URL containing abc.
#   {% href match abc.html#tag The Awesome %}
#
# @example Substitute name/value pair for the django-github variable:
# {% href {{django-github}}/django/core/management/__init__.py#L398-L401
#   <code>django.core.management.execute_from_command_line</code> %}

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
  def render(liquid_context)
    _content = super
    @helper.liquid_context = liquid_context

    @site = liquid_context.registers[:site]
    JekyllAllCollections::maybe_compute_all_collections(@site)

    @match = @helper.parameter_specified?('match')
    @url   = @helper.parameter_specified?('url')

    if @match
      match(liquid_context)
      @follow = ''
      @target = ''
    else
      @follow = @helper.parameter_specified?('follow') ?   " rel='nofollow'"  : ''
      @target = @helper.parameter_specified?('notarget') ? " target='_blank'" : ''
    end

    if @url
      link = @url
    else
      link = @helper.argv.shift
    end
    link = JekyllTagHelper2.expand_env(link)
    finalize(@helper.argv, link)
    @link = replace_vars(liquid_context, @link)

    @target = @follow = '' if @link.start_with? 'mailto:'
    @logger.debug { "@link=#{@link}" }
    "<a href='#{@link}'#{@target}#{@follow}>#{@text}</a>"
  end

  private

  def finalize(tokens, link)
    @text = tokens.join(" ").strip
    if @text.empty?
      @text = "<code>#{link}</code>"
      @link = "https://#{link}"
    else
      @link = link
    end

    unless @link.start_with? "http"
      @follow = ''
      @target = ''
    end
  end

  def match(liquid_context) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    config = @site.config['href']
    die_if_nomatch = !config.nil? && config['nomatch'] && config['nomatch']=='fatal'

    path, fragment = @link.split('#')

    @logger.debug {
      <<~END_DEBUG
        @link=#{@link}
        @site.posts.docs[0].url  = #{@site.posts.docs[0].url}
        @site.posts.docs[0].path = #{@site.posts.docs[0].path}
      END_DEBUG
    }

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
      abort "Error: More than one url matched '#{path}': #{ url_matches.join(", ")}"
    end
  end

  def replace_vars(liquid_context, link)
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
