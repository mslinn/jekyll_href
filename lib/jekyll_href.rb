# frozen_string_literal: true

require "jekyll_plugin_logger"
require_relative "jekyll_href/version"

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

module Jekyll
  class ExternalHref < Liquid::Tag
    # @param tag_name [String] is the name of the tag, which we already know.
    # @param command_line [Hash, String, Liquid::Tag::Parser] the arguments from the web page.
    # @param tokens [Liquid::ParseContext] tokenized command line
    # @return [void]
    def initialize(tag_name, command_line, tokens)
      super

      @match = false
      @tokens = command_line.strip.split
      @follow = get_value("follow", " rel='nofollow'")
      @target = get_value("notarget", " target='_blank'")

      match_index = tokens.index("match")
      if match_index
        tokens.delete_at(match_index)
        @follow = ""
        @match = true
        @target = ""
      end

      finalize tokens
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # @return [String]
    def render(context)
      match(context) if @match
      link = replace_vars(context, @link)
      debug { "@link=#{@link}; link=#{link}" }
      "<a href='#{link}'#{@target}#{@follow}>#{@text}</a>"
    end

    private

    def finalize(tokens)
      @link = tokens.shift

      @text = tokens.join(" ").strip
      if @text.empty?
        @text = "<code>${@link}</code>"
        @link = "https://#{@link}"
      end

      unless @link.start_with? "http"
        @follow = ""
        @target = ""
      end
    end

    def get_value(token, default_value)
      value = default_value
      target_index = tokens.index(token)
      if target_index
        @tokens.delete_at(target_index)
        value = ""
      end
      value
    end

    def match(context) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      site = context.registers[:site]
      config = site.config['href']
      die_if_nomatch = !config.nil? && config['nomatch'] && config['nomatch']=='fatal'

      path, fragment = @link.split('#')

      debug { "@link=#{@link}" }
      debug { "site.posts[0].url  = #{site.posts.docs[0].url}" }
      debug { "site.posts[0].path = #{site.posts.docs[0].path}" }
      posts = site.posts.docs.select { |x| x.url.include?(path) }
      case posts.length
      when 0
        if die_if_nomatch
          abort "href error: No url matches '#{@link}'"
        else
          @link = "#"
          @text = "<i>#{@link} is not available</i>"
        end
      when 1
        @link = "#{@link}\##{fragment}" if fragment
      else
        abort "Error: More than one url matched: #{ matches.join(", ")}"
      end
    end

    def replace_vars(context, link)
      variables = context.registers[:site].config['plugin-vars']
      variables.each do |name, value|
        # puts "#{name}=#{value}"
        link = link.gsub("{{#{name}}}", value)
      end
      link
    end
  end
  info { "Loaded jeykll_href plugin." }
end

Liquid::Template.register_tag('href', Jekyll::ExternalHref)
