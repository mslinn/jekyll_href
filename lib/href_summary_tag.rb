require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'
require_relative 'jekyll_href/version'

module HrefSummaryTag
  class HrefSummary < JekyllSupport::JekyllTag
    include JekyllHrefVersion

    # Class instance variables accumulate hrefs across invocations.
    # These are hashes of arrays;
    # the hash keys are page paths (strings) and the hash values are arrays of HRef summary strings.
    # {
    #   'path/to/page1.html': [ "HRef1", "HRef2" ],
    #   'path/to/page2.html': [ "HRef3", "HRef4" ],
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
      entries = self.class.hrefs.map do |href|
        "<li>#{href.summarize}</li>"
      end

      return '' if entries.empty?

      <<~END_RENDER
        <h2 id="reference">References</h2>
        <ol>
          #{entries.join("\n  ")}
        </ol>#{local_refs if @include_local}
      END_RENDER
    end

    def local_refs
      entries = self.class.hrefs_local.map do |href|
        "<li>#{href.summarize}</li>"
      end
      <<~END_RENDER


        <h2 id="local_reference">Internal References</h2>
        <ol>
        #{entries.join("\n  ")}
        </ol>
      END_RENDER
    end

    JekyllPluginHelper.register(self, 'href_summary')
  end
end
