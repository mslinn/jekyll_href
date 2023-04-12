require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'
require_relative 'jekyll_href/version'

module HrefSummaryTag
  class HrefSummary < JekyllSupport::JekyllTag # rubocop:disable Metrics/ClassLength
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
      @include_local = @helper.parameter_specified? 'include_local'
      global_refs = render_global_refs
      local_refs  = render_local_refs
      have_refs = !(global_refs + local_refs).empty?
      <<~END_RENDER
        #{global_refs}
        #{local_refs}
        #{@helper.attribute if @helper.attribution && have_refs}
      END_RENDER
    end

    def render_global_refs
      hrefs = HashArray.instance_variable_get(:@global_hrefs)
      path = @page['path']
      entries = hrefs[path]&.select { |h| h.path == path }
      return '' if entries.nil? || entries.empty?

      summaries = entries.reverse.map { |href| "<li>#{href.summary_href}</li>" }

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
      path = @page['path']
      entries = hrefs[path]&.select { |h| h.path == path }
      return '' if entries.nil? || entries.empty?

      summary = entries.reverse.map { |href| "<li>#{href.summary_href}</li>" }
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
