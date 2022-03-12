# frozen_string_literal: true

require 'jekyll'
require_relative '../lib/jekyll_href'

RSpec.describe(JekyllHref::ExternalHref) do
  let(:config) do
    { :href => { :nomatch => 'fatal' } }
  end

  let(:site) do
    site_ = instance_double("Site")
    allow(site_).to receive(:source) { Dir.pwd }
    allow(site_).to receive(:config) { config }
    allow(site_).to receive(:pages) { [page1] }
    allow(site_).to receive(:posts) { [] }
    site_
  end

  let(:context) do
    context_ = instance_double("Context")
    allow(context_).to receive(:registers) { { :site => config } }
  end

  let(:page) do
    page_ = instance_double("Page")
    allow(page_).to receive(:path) { 'spec/fixtures/test.html' }
    allow(page_).to receive(:data) { {} }
    page_
  end

  let(:page1) do
    Jekyll::PageOrPost.new(config, auto_site, page)
  end

  it 'renders' do
    link = 'https://mslinn.com'
    text = 'mslinn.com'
    command_line = "#{link} #{text}"
    target = 'target="_blank"'
    follow = 'rel="nofollow"'
    context = Liquid::ParseContext.new
    href = JekyllHref::ExternalHref.send :new, 'href', command_line, context
    expect(href.render).to eq "<a href='#{link}'#{target}#{follow}>#{text}</a>"
  end
end
