# frozen_string_literal: true

require "jekyll"
require "jekyll_plugin_logger"
require_relative "../lib/jekyll_href"

# Lets get this party started
Registers = Struct.new(:page, :site)

# More party
class TestParseContext < Liquid::ParseContext
  attr_reader :registers

  def initialize
    super
    @registers = Registers.new(
      { 'path' => 'https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss' },
      { 'name' => 'You asked for a site name' }
    )
  end
end

# Lets get this party started
class MyTest
  RSpec.describe ExternalHref do
    let(:logger) do
      PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
    end

    let(:parse_context) do
      pc = TestParseContext.new
      allow(pc).to receive(:line_number)
      allow(pc).to receive(:registers)
      pc
    end

    let(:helper) do
      JekyllTagHelper2.new(
        'href',
        'mailto:j.smith@super-fake-merger.com',
        logger
      )
    end

    let(:href) do
      ExternalHref.send(
        :new,
        'href',
        'https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss  SoundCloud RSS Feed'.dup,
        parse_context
      )
    end

    it "does stuff" do
      href.send(:globals_initial, parse_context)
      url = href.url
      expect(url).to eq('https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss')
    end
  end
end
