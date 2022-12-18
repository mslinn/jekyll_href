# frozen_string_literal: true

require "jekyll"
require "jekyll_plugin_logger"
require_relative "../lib/jekyll_href"

Registers = Struct.new(:page, :site)

# Mock for Collections
class Collections
  def values
    []
  end
end

# Mock for Site
class SiteMock
  def collections
    Collections.new
  end
end

# Mock for Liquid::ParseContent
class TestParseContext < Liquid::ParseContext
  attr_reader :line_number, :registers

  def initialize
    super
    @line_number = 123

    @registers = Registers.new(
      { 'path' => 'https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss' },
      SiteMock.new
    )
  end
end

# Lets get this party started
class MyTest
  RSpec.describe ExternalHref do
    let(:logger) do
      PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    end

    let(:parse_context) { TestParseContext.new }

    let(:helper) do
      JekyllTagHelper2.new(
        'href',
        'mailto:j.smith@super-fake-merger.com',
        logger
      )
    end

    it "Obtains external link without text" do
      href = ExternalHref.send(
        :new,
        'href',
        'https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss  SoundCloud RSS Feed'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.link).to eq('https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss')
    end
  end
end
