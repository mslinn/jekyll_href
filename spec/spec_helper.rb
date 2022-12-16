# frozen_string_literal: true

require "liquid"
require "fileutils"
require_relative "../lib/jekyll_href"

RSpec.configure do |config|
  config.filter_run :focus
  config.order = "random"
  config.run_all_when_everything_filtered = true

  # See https://relishapp.com/rspec/rspec-core/docs/command-line/only-failures
  config.example_status_persistence_file_path = "spec/status_persistence.txt"
end
