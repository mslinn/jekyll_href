# frozen_string_literal: true

require 'jekyll'
require_relative '../lib/jekyll_href'

RSpec.describe(JekyllHref::HrefTag) do
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
    # options = {
    #   'baseurl'     => '',
    #   'cache_dir'   => '',
    #   'destination' => './_site',
    #   'exclude'     => ["Gemfile", "Gemfile.lock", "node_modules", "vendor/bundle/", "vendor/cache/", "vendor/gems/", "vendor/ruby/"],
    #   'future'      => false,
    #   'gems'        => [],
    #   'highlighter' => 'rouge',
    #   'include'     => ['.htaccess'],
    #   'keep_files'  => [".git", ".svn"],
    #   'liquid'      => { 'error_mode' => 'lax' },
    #   'limit_posts' => 0,
    #   'lsi'         => false,
    #   'permalink'   => 'date',
    #   'plugins'     => [],
    #   'safe'        => false,
    #   'show_drafts' => false,
    #   'source'      => '.',
    #   'unpublished' => false,
    # }
    context = Liquid::Context.new({}, {}, { :site => { :config => Jekyll::Configuration.from({}) } })
    def context.line_number
      1
    end

    # See https://jekyllrb.com/docs/configuration/default/
    @site = Jekyll::Site.new(context.registers[:site][:config])
    # This seems close, but HrefRender.initialize gets a context without any registers (empty hash). Not sure what to do about that.
    @context = Liquid::Context.new(@site.site_payload, {}, :site => @site)
    # site = @context.registers[:site]
    # def site.config
    #   @context.registers[:site].config
    # end

    link = 'https://mslinn.com'
    follow = 'rel="nofollow"'
    target = 'target="_blank"'
    text = 'mslinn.com'

    command_line = "#{link} #{text}"
    href = JekyllHref::HrefTag.send :new, 'href', command_line, context
    expect(href.render(context)).to eq "<a href='#{link}'#{target}#{follow}>#{text}</a>"
  end
end
