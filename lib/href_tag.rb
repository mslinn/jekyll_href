require 'ipaddress'
require 'jekyll_draft'
require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'
require 'liquid'
require_relative 'enums'
require_relative 'jekyll_href/version'
require_relative 'hash_array'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
# Generates an href.

module JekyllSupport
  MiniHref = Struct.new(:follow, :html, :link, :line_number, :link_save, :path, :summary_exclude, :summary_href, keyword_init: true) do
    def to_s
      # "On line #{line_number} of #{path}:"
      msg = '<HRef'
      msg += follow unless follow.empty?
      # msg += " match='#{match}'" if match
      msg += " path='#{path}'" # if path
      # msg += target unless target.empty?
      msg += " link='#{link}'" # unless link.empty?
      msg += " text='#{html}'" unless html.empty?
      msg += '>'
      msg
    end

    def inspect = to_s
  end

  # Implements href Jekyll tag
  class HRefTag < JekyllTag
    attr_reader :follow, :helper, :line_number, :link_save, :match, :page, :path, :site,
                :summary, :summary_exclude, :summary_href, :target, :text, :url
    attr_accessor :link

    include JekyllHrefVersion
    include HashArray
    include Comparable

    def ==(other)
      case other
      when self.class
        follow == other.follow &&
          match == other.match &&
          path == other.path &&
          target == other.target &&
          text == other.text
      when MiniHref
        follow == other.follow &&
          text == other.html &&
          link == other.link &&
          line_number == other.line_number &&
          link_save == other.link_save &&
          path == other.path &&
          summary_exclude == other.summary_exclude &&
          summary_href == other.summary_href
      else
        false
      end
    end

    def <=>(other)
      return nil unless other.is_a?(self.class)

      [follow, match, path, target, text] <=> [other.follow, other.match, other.path, other.target, other.text]
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # @param liquid_context [Liquid::Context]
    # @return [String]
    def render_impl
      globals_initial
      linkk, error_msg = compute_linkk
      return error_msg unless linkk

      linkk.delete_prefix './' # normalize relative links
      @url = linkk if @url
      @link_save = linkk

      @helper_save = @helper.clone
      globals_update(@helper.argv, linkk) # Sets @link and @text, might clear @follow and @target
      handle_match(linkk) if @match # Sets @text if not set by now, also @link_type, etc.

      @link.gsub! ' ', '%20'

      raise HrefError, '@link_type was not set' if @link_type == LinkType::UNKNOWN

      save_summary

      klass = " class='#{@klass}'" if @klass
      style = " style='#{@style}'" if @style

      if @link_type == LinkType::LOCAL &&
         @mode == 'production' &&
         @label_source != LabelSource::FROM_IMPLICIT_LABEL &&
         @link != '#'
        path, _fragment = @link.split('#')
        page = ::Jekyll::Draft.page_match path
        if ::Jekyll::Draft.draft? page
          klass = "draft_link #{@klass}".strip
          raise HrefError,
                "<span class='#{klass}'#{style}><span class='draft_title'>#{page.title}</span> <span class='draft_label'>#{@text}</span></span>"
        end
      end

      "<a href='#{@link}'#{klass}#{style}#{@target}#{@follow}>#{@text}</a>"
    rescue HrefError => e # jekyll_plugin_support handles StandardError
      @logger.error { JekyllPluginHelper.remove_html_tags e.logger_message }
      exit 1 if @die_on_demo_tag_error

      e.html_message
    end

    def to_s
      # "On line #{line_number} of #{path}:"
      msg = '<HRef'
      msg += follow unless follow.empty?
      msg += " match='#{match}'" if match
      msg += " path='#{path}'" # if path
      msg += target unless target.empty?
      msg += " link='#{link}'" # unless link.empty?
      msg += " text='#{text}'" unless text.empty?
      msg += '>'
      msg
    end

    def inspect
      # "On line #{line_number} of #{path}:"
      msg = '<HRef'
      msg += follow unless follow.empty?
      msg += " match='#{match}'" if match
      msg += " path='#{path}'" # if path
      msg += target unless target.empty?
      msg += " link='#{link}'" # unless link.empty?
      msg += " text='#{text[0..20]}#{text.length > 20 ? "'..." : "'"}" unless text.empty?
      msg += '>'
      msg
    end

    JekyllSupport::JekyllPluginHelper.register(self, 'href')
  end
end

require_relative 'href_match'
require_relative 'href_private'
require_relative 'href_page_title'
require_relative 'href_summary'
