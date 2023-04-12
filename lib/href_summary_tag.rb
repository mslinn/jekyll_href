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
      render_refs
    end

    def render_refs
      hrefs = HashArray.instance_variable_get(:@global_hrefs)
      puts "hrefs=#{hrefs}"
      path = @page['path']
      puts "path=#{path}"
      entries = hrefs[path]&.select { |h| h.path == path }
      puts "entries=#{entries}"
      return '' if entries.empty?

      summaries = entries.map { |href| "<li>#{href.summary_href}</li>" }

      <<~END_RENDER
        <h2 id="reference">References</h2>
        <ol>
          #{summaries.join "\n  "}
        </ol>#{local_refs if @include_local}
        #{@helper.attribute if @helper.attribution}
      END_RENDER
    rescue StandardError => e
      @logger.error { "#{self.class} died with a #{e.full_message}" }
      exit 1
    end

    def local_refs
      hrefs = HashArray.instance_variable_get(:@local_hrefs)
      path = @page['path']
      entries = hrefs[path]&.select { |h| h.path == path }
      return '' if entries.empty?

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
