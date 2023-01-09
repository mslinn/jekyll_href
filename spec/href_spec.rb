# frozen_string_literal: true

require 'jekyll'
require 'jekyll_plugin_logger'
require 'yaml'
require_relative '../lib/jekyll_href'

Registers = Struct.new(:page, :site)

# Mock for Collections
class Collections
  def values
    []
  end
end

# Mock for Site
class SiteMock
  attr_reader :config

  def initialize
    @config = YAML.safe_load(File.read('_config.yml'))
  end

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
class MyTest # rubocop:disable Metrics/ClassLength
  Dir.chdir 'demo'

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

    it "Obtains internal link with blank" do
      href = ExternalHref.send(
        :new,
        'href',
        'blank ./path/page.html internal link text'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq('')
      expect(href.link).to   eq('./path/page.html')
      expect(href.target).to eq(" target='_blank'")
      expect(href.text).to   eq('internal link text')
    end

    it "Obtains external link with text" do
      href = ExternalHref.send(
        :new,
        'href',
        'https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss  SoundCloud RSS Feed'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq(" rel='nofollow'")
      expect(href.link).to   eq('https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss')
      expect(href.target).to eq(" target='_blank'")
      expect(href.text).to   eq('SoundCloud RSS Feed')
    end

    it "Obtains external link using url parameter with text" do
      href = ExternalHref.send(
        :new,
        'href',
        'url="https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss" SoundCloud RSS Feed'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq(" rel='nofollow'")
      expect(href.link).to   eq('https://feeds.soundcloud.com/users/soundcloud:users:7143896/sounds.rss')
      expect(href.target).to eq(" target='_blank'")
      expect(href.text).to   eq('SoundCloud RSS Feed')
    end

    it "Obtains external link without scheme or text" do
      href = ExternalHref.send(
        :new,
        'href',
        'super-fake-merger.com'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq(" rel='nofollow'")
      expect(href.link).to   eq('https://super-fake-merger.com')
      expect(href.target).to eq(" target='_blank'")
      expect(href.text).to   eq('<code>super-fake-merger.com</code>')
    end

    it "Expands YAML hash with link text" do
      href = ExternalHref.send(
        :new,
        'href',
        '{{github}}/diasks2/confidential_info_redactor <code>confidential_info_redactor</code>'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      linkk = href.send(:replace_vars, linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq(" rel='nofollow'")
      expect(href.link).to   eq('https://github.com/diasks2/confidential_info_redactor')
      expect(href.target).to eq(" target='_blank'")
      expect(href.text).to   eq('<code>confidential_info_redactor</code>')
    end

    it "Obtains external link with follow" do
      href = ExternalHref.send(
        :new,
        'href',
        'follow https://www.mslinn.com Awesome'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq('')
      expect(href.link).to   eq('https://www.mslinn.com')
      expect(href.target).to eq(" target='_blank'")
      expect(href.text).to   eq('Awesome')
    end

    it "Obtains external link with follow and notarget" do
      href = ExternalHref.send(
        :new,
        'href',
        'follow notarget https://www.mslinn.com Awesome'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq('')
      expect(href.link).to   eq('https://www.mslinn.com')
      expect(href.target).to eq('')
      expect(href.text).to   eq('Awesome')
    end

    it "Obtains external link with blank" do
      href = ExternalHref.send(
        :new,
        'href',
        'blank https://www.mslinn.com Awesome'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq(" rel='nofollow'")
      expect(href.link).to   eq('https://www.mslinn.com')
      expect(href.target).to eq(" target='_blank'")
      expect(href.text).to   eq('Awesome')
    end

    it "Implicitly computes external link from text" do
      href = ExternalHref.send(
        :new,
        'href',
        'www.mslinn.com'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq(" rel='nofollow'")
      expect(href.link).to   eq('https://www.mslinn.com')
      expect(href.target).to eq(" target='_blank'")
      expect(href.text).to   eq('<code>www.mslinn.com</code>')
    end

    it "Implicitly computes external link from text with follow and notarget" do
      href = ExternalHref.send(
        :new,
        'href',
        'follow notarget www.mslinn.com'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq('')
      expect(href.link).to   eq('https://www.mslinn.com')
      expect(href.target).to eq('')
      expect(href.text).to   eq('<code>www.mslinn.com</code>')
    end

    it "Implicitly computes external link from text with blank" do
      href = ExternalHref.send(
        :new,
        'href',
        'follow blank www.mslinn.com'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq('')
      expect(href.link).to   eq('https://www.mslinn.com')
      expect(href.target).to eq(" target='_blank'")
      expect(href.text).to   eq('<code>www.mslinn.com</code>')
    end

    it "Obtains mailto without text" do
      href = ExternalHref.send(
        :new,
        'href',
        'mailto:mslinn@mslinn.com'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq('')
      expect(href.link).to   eq('mailto:mslinn@mslinn.com')
      expect(href.target).to eq('')
      expect(href.text).to   eq('<code>mslinn@mslinn.com</code>')
    end

    it "Obtains mailto with text" do
      href = ExternalHref.send(
        :new,
        'href',
        'mailto:mslinn@mslinn.com Mike Slinn'.dup,
        parse_context
      )
      href.send(:globals_initial, parse_context)
      linkk = href.send(:compute_linkk)
      href.send(:globals_update, href.helper.argv, linkk)
      expect(href.follow).to eq('')
      expect(href.link).to   eq('mailto:mslinn@mslinn.com')
      expect(href.target).to eq('')
      expect(href.text).to   eq('Mike Slinn')
    end
  end
end
