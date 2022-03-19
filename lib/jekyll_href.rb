# frozen_string_literal: true

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
module JekyllHref
  class HrefSetup
    attr_reader :follow, :match_keyword, :tokens, :target, :text

    def initialize(tag_line, parse_context)
      @tokens = tag_line.strip.split
      @parse_context = parse_context
      @follow = get_value('follow', " rel='nofollow'")
      @target = get_value('notarget', " target='_blank'")

      @match_keyword = false
      match_index = @tokens.index('match')
      if match_index
        context.delete_at(match_index)
        @follow = ''
        @match_keyword = true
        @target = ''
      end

      finalize
    end

    def replace_vars(variables)
      variables.each do |name, value|
        @link = @link.gsub("{{#{name}}}", value)
      end
      @link
    end

    private

    def finalize
      @link = @tokens.shift

      @text = @tokens.join(' ').strip
      if @text.empty?
        @text = "<code>#{@link}</code>"
        @link = "https://#{@link}"
      end

      unless @link.start_with? 'http'
        @follow = ''
        @target = ''
      end
    end

    def get_value(token, default_value)
      value = default_value
      target_index = @tokens.index(token)
      if target_index
        @tokens.delete_at(target_index)
        value = ""
      end
      value
    end
  end

  class HrefRender
    def initialize(context, href_setup)
      @context = context
      @site = @context.registers[:site]
      @config = @site.config
      @href_setup = href_setup
      match(context) if @href_setup.match_keyword
    end

    def link
      @href_setup.replace_vars @config['plugin-vars']
    end

    private

    def handle_no_args
      href_config = @config['href']
      die_if_nomatch = !href_config.nil? &&
                        href_config['nomatch'] &&
                        href_config['nomatch'] == 'fatal'
      if die_if_nomatch
        abort "href error: No url matches '#{@link}'"
      else
        @link = "#"
        @text = "<i>#{@link} is not available</i>"
      end
    end

    def match
      path, fragment = @link.split('#')
      posts = @site.posts.docs.select { |x| x.url.include?(path) }
      case posts.length
      when 0
        handle_no_args
      when 1
        @link = "#{@link}\##{fragment}" if fragment
      else
        abort "Error: More than one url matched: #{matches.join(", ")}"
      end
    end
  end

  class HrefTag < Liquid::Tag
    # @param tag_name [String] is the name of the tag, which we already know.
    # @param tag_line [Hash, String, Liquid::Tag::Parser] the contents between {% and %} in the web page (should be a string).
    # @param parse_context [Liquid::ParseContext] looks like:
    #   <Liquid::ParseContext:0x00005595446e5800
    #     @template_options={
    #       :line_numbers=>true,
    #       :locale=>#<Liquid::I18n:0x00005595446e5760 @path="/home/mslinn/.gems/gems/liquid-4.0.3/lib/liquid/locales/en.yml">},
    #     @locale=#<Liquid::I18n:0x00005595446e5760
    #     @path="/home/mslinn/.gems/gems/liquid-4.0.3/lib/liquid/locales/en.yml">,
    #     @warnings=[],
    #     @depth=0,
    #     @partial=false,
    #     @options={:line_numbers=>true, :locale=>#<Liquid::I18n:0x00005595446e5760
    #     @path="/home/mslinn/.gems/gems/liquid-4.0.3/lib/liquid/locales/en.yml">},
    #     @error_mode=:strict,
    #     @line_number=9,
    #     @trim_whitespace=false>
    # @return [void]
    def initialize(tag_name, tag_line, parse_context)
      super
      @href_setup = HrefSetup.new(tag_line, parse_context)
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # @param context [Liquid::Context] Context keeps the variable stack and resolves variables, as well as keywords
    # @return [String]
    def render(context)
      href_render = HrefRender.new(context, @href_setup)
      "<a href='#{href_render.link}'#{@href_setup.target}#{@href_setup.follow}>#{@href_setup.text}</a>"
    end
  end
end

Liquid::Template.register_tag('href', JekyllHref::HrefTag)
