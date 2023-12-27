require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'
require_relative 'jekyll_href/version'

module MSlinn
  class HrefSummary < JekyllSupport::JekyllTag
    include JekyllHrefVersion

    # Class instance variables accumulate hrefs across invocations.
    # These are hashes of arrays;
    # the hash keys are page paths (strings) and the hash values are arrays of HRefTags.
    # {
    #   'path/to/page1.html': [ HRefTag1, HRefTag2 ],
    #   'path/to/page2.html': [ HRefTag3, HRefTag4 ],
    # }
    @hrefs = {}
    @hrefs_local = {}

    class << self
      attr_accessor :hrefs, :hrefs_local
    end

    include JekyllHrefVersion

    # Method prescribed by the Jekyll plugin lifecycle.
    # @param liquid_context [Liquid::Context]
    # @return [String]
    def render_impl
      @helper.gem_file __FILE__ # Enables attribution
      @include_local = @helper.parameter_specified? 'include_local'

      @die_on_href_error = @tag_config['die_on_href_error'] == true if @tag_config
      @pry_on_href_error = @tag_config['pry_on_href_error'] == true if @tag_config

      @path = @page['path']
      global_refs = render_global_refs
      local_refs  = render_local_refs
      have_refs = !(global_refs + local_refs).empty?
      <<~END_RENDER
        #{global_refs}
        #{local_refs}
        #{@helper.attribute if @helper.attribution && have_refs}
      END_RENDER
    rescue HRefError => e # jekyll_plugin_support handles StandardError
      e.shorten_backtrace
      msg = format_error_message e.message
      @logger.error "#{e.class} raised #{msg}"
      binding.pry if @pry_on_img_error # rubocop:disable Lint/Debugger
      raise e if @die_on_href_error

      "<div class='href_error'>#{e.class} raised in #{self.class};\n#{msg}</div>"
    end

    def render_global_refs
      hrefs = HashArray.instance_variable_get(:@global_hrefs)
      entries = hrefs[@path]&.select { |h| h.path == @path }
      return '' if entries.nil? || entries.empty?

      summaries = entries.map { |href| "<li>#{href.summary_href}</li>" }

      <<~END_RENDER
        <h2 id="reference">References</h2>
        <ol>
          #{summaries.join "\n  "}
        </ol>
      END_RENDER
    rescue StandardError => e
      @logger.error { "#{self.class} died with a #{e.full_message}" }
      exit 1
    end

    def render_local_refs
      return '' unless @include_local

      hrefs = HashArray.instance_variable_get(:@local_hrefs)
      entries = hrefs[@path]&.select { |h| h.path == @path }
      return '' if entries.nil? || entries.empty?

      summary = entries.map { |href| "<li>#{href.summary_href}</li>" }
      <<~END_RENDER
        <h2 id="local_reference">Local References</h2>
        <ol>
        #{summary.join("\n  ")}
        </ol>
      END_RENDER
    end

    JekyllPluginHelper.register(self, 'href_summary')
  end
end
