require_relative 'href_tag'
require_relative 'href_summary_tag'

HrefError = Class.new(Liquid::Error)

module JekyllHrefModule
  include MSlinn
end
