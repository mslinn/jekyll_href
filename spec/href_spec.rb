# frozen_string_literal: true

require "jekyll"
require "jekyll_plugin_logger"
require_relative "../lib/jekyll_href"

# Lets get this party started
Registers = Struct.new(:page, :site)

# More party
class TestParseContext < Liquid::ParseContext
  attr_reader :blah, :line_number, :registers

  def initialize
    super
    @line_number = 123

    @registers = Registers.new(
      { 'path' => 'https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss' },
      { 'name' => 'You asked for a site name' }
    )

    @blah = 456
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

    it "does stuff" do
      href = ExternalHref.send(
        :new,
        'href',
        'https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss  SoundCloud RSS Feed'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      url = href.url
      expect(url).to eq('https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss')
    end
  end
end
