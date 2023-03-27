require 'jekyll_plugin_logger'
require 'jekyll_plugin_support'
require_relative 'jekyll_href/version'

module HrefSummaryTag
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
      @include_local = @helper.parameter_specified? 'include_local'
      render_refs
    end

    def render_refs
      hrefs = HashArray.instance_variable_get(:@global_hrefs)
      path = @page['path']
      entries = hrefs[path]
                  &.find { |h| h.path == path }
                  &.map  { |h| "<li>#{h.summary}</li>" }
      return '' if entries.to_s.empty?

      <<~END_RENDER
        <h2 id="reference">References</h2>
        <ol>
          #{entries.join("\n  ")}
        </ol>#{local_refs if @include_local}
      END_RENDER
    end

    def local_refs
      hrefs = HashArray.instance_variable_get(:@local_hrefs)
      path = @page['path']
      entries = hrefs.find(path) do |link|
        "<li>#{link}</li>"
      end
      return '' if entries.to_s.empty?

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
