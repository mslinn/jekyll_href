require 'ipaddress'
require 'jekyll_draft'
require 'jekyll_all_collections'
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
  MiniHref = Struct.new(:follow, :html, :link, :line_number, :link_save, :path, :summary_exclude, :summary_href, keyword_init: true)

  HRefError = JekyllSupport.define_error

  # Implements href Jekyll tag
  class HRefTag < JekyllTag
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
      raise HrefError, '@link_type was not set' if @link_type == LinkType::UNKNOWN

      save_summary
      klass = " class='#{@klass}'" if @klass
      style = " style='#{@style}'" if @style
      if @link_type == LinkType::LOCAL && local_page_draft?(@link)
        klass = "draft_link #{klass}".strip
        return "<span #{klass}#{style} title='This page is not available yet.'>#{@text}</span>" if @mode == 'production'
      end

      "<a href='#{@link}'#{klass}#{style}#{@target}#{@follow}>#{@text}</a>"
    rescue HRefError => e # jekyll_plugin_support handles StandardError
      @logger.error { e.logger_message }
      exit 1 if @die_on_demo_tag_error

      e.html_message
    end

    def to_s
      "On line #{line_number} of #{path}: #{follow} #{match} #{target} #{link} => '#{text}'"
    end

    def local_page_draft?(url)
      filetype = File.extname url
      page_matches = @site.all_collections.map.select { |page| page.url == url }
      case page_matches.length
      when 0
        return false unless %w[htm html md].include? filetype

        msg = "HRef error: No url matches '#{url}', found on line #{@line_number} (after front matter)"
        @logger.error { msg }
        abort msg if @die_if_nomatch

        @text = "<i class='h_ref_error'>#{url} is not a valid local page</i>"
        @link_save = @link = '#'
        true
      when 1
        @link = page_matches.first.url
        @link = "#{@link}##{@fragment}" if @fragment
        @link_save = @link
        @text = page_matches.first.title unless @label
        Jekyll::Draft.draft? page_matches.first
      else
        logger.error { "Error: More than one url matched '#{url}, mentioned in #{@path}'.\nCollections are: #{page_matches.join(', ')}" }
        exit! 2
      end
    end

    JekyllSupport::JekyllPluginHelper.register(self, 'href')
  end
end

require_relative 'href_match'
require_relative 'href_private'
require_relative 'href_page_title'
require_relative 'href_summary'
