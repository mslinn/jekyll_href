require_relative 'lib/jekyll_href/version'

Gem::Specification.new do |spec|
  github = 'https://github.com/mslinn/jekyll_href'

  spec.authors = ['Mike Slinn']
  spec.bindir = 'exe'
  spec.description = <<~END_OF_DESC
    Generates an 'a href' tag, possibly with target='_blank' and rel='nofollow'.
  END_OF_DESC
  spec.email = ['mslinn@mslinn.com']
  spec.files = Dir['.rubocop.yml', 'LICENSE.*', 'Rakefile', '{lib,spec}/**/*', '*.gemspec', '*.md']
  spec.homepage = 'https://www.mslinn.com/jekyll_plugins/jekyll_href.html'
  spec.license = 'MIT'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => "#{github}/issues",
    'changelog_uri'     => "#{github}/CHANGELOG.md",
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => github,
  }
  spec.name = 'jekyll_href'
  spec.post_install_message = <<~END_MESSAGE

    Thanks for installing #{spec.name}!

  END_MESSAGE
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.6.0'
  spec.summary = "Generates an 'a href' tag, possibly with target='_blank' and rel='nofollow'."
  spec.version = JekyllHrefVersion::VERSION

  spec.add_dependency 'ipaddress'
  spec.add_dependency 'jekyll', '>= 3.5.0'
  spec.add_dependency 'jekyll_all_collections', '>= 0.3.3'
  spec.add_dependency 'jekyll_plugin_support', '>= 0.8.1'
  spec.add_dependency 'typesafe_enum'
end
