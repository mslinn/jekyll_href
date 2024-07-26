require 'ipaddress'
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

module MSlinn
  MiniHref = Struct.new(:follow, :html, :link, :line_number, :link_save, :path, :summary_exclude, :summary_href, keyword_init: true)

  HRefError = JekyllSupport.define_error

  # Implements href Jekyll tag
  class HRefTag < JekyllSupport::JekyllTag
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
      handle_match(@link) if @match
      raise HrefError, '@link_type was not set' if @link_type == LinkType::UNKNOWN

      save_summary
      klass = " class='#{@klass}'" if @klass
      style = " style='#{@style}'" if @style
      "<a href='#{@link}'#{klass}#{style}#{@target}#{@follow}>#{@text}</a>"
    rescue HRefError => e # jekyll_plugin_support handles StandardError
      msg = format_error_message "#{e.message}\n<pre>  {% href #{@argument_string.strip} %}</pre>"
      @text = "<div class='href_error'>#{msg}</div>"
      e.shorten_backtrace
      @logger.error "#{e.class} raised #{msg}"
      binding.pry if @pry_on_img_error # rubocop:disable Lint/Debugger
      raise e if @die_on_href_error

      "<div class='href_error'>#{e.class} raised in #{self.class};\n#{msg}</div>"
    end

    def to_s
      "On line #{line_number} of #{path}: #{follow} #{match} #{target} #{link} => '#{text}'"
    end

    JekyllSupport::JekyllPluginHelper.register(self, 'href')
  end
end

require_relative 'href_match'
require_relative 'href_private'
require_relative 'href_page_title'
require_relative 'href_summary'
