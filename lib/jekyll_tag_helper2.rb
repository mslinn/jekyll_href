# frozen_string_literal: true

require 'shellwords'
require 'key_value_parser'

# Parses arguments and options
class JekyllTagHelper2
  attr_reader :argv, :liquid_context, :logger, :params, :tag_name

  # Expand a environment variable reference
  def self.expand_env(str, die_if_undefined: false)
    str.gsub(/\$([a-zA-Z_][a-zA-Z0-9_]*)|\${\g<1>}|%\g<1>%/) do
      envar = Regexp.last_match(1)
      raise FlexibleError, "flexible_include error: #{envar} is undefined".red, [] \
        if !ENV.key?(envar) && die_if_undefined # Suppress stack trace

      ENV[envar]
    end
  end

  # strip leading and trailing quotes if present
  def self.remove_quotes(string)
    string.strip.gsub(/\A'|\A"|'\Z|"\Z/, '').strip if string
  end

  def initialize(tag_name, markup, logger)
    # @keys_values was a Hash[Symbol, String|Boolean] but now it is Hash[String, String|Boolean]
    @tag_name = tag_name
    @argv = Shellwords.split(JekyllTagHelper2.expand_env(markup))
    @keys_values = KeyValueParser \
      .new({}, { array_values: false, normalize_keys: false, separator: /=/ }) \
      .parse(@argv)
    @logger = logger
    @logger.debug { "@keys_values='#{@keys_values}'" }
  end

  def delete_parameter(key)
    return if @keys_values.empty?

    @params.delete(key)
    @argv.delete_if { |x| x == key or x.start_with? "#{key}=" }
    @keys_values.delete(key)
  end

  # @return if parameter was specified, removes it from the available tokens and returns value
  def parameter_specified?(name)
    return false if @keys_values.empty?

    key = name
    key = name.to_sym if @keys_values.first.first.instance_of?(Symbol)
    value = @keys_values[key]
    delete_parameter(name)
    value
  end

  PREDEFINED_SCOPE_KEYS = %i[include page].freeze

  # Finds variables defined in an invoking include, or maybe somewhere else
  # @return variable value or nil
  def dereference_include_variable(name)
    @liquid_context.scopes.each do |scope|
      next if PREDEFINED_SCOPE_KEYS.include? scope.keys.first

      value = scope[name]
      return value if value
    end
    nil
  end

  # @return value of variable, or the empty string
  def dereference_variable(name)
    value = @liquid_context[name] # Finds variables named like 'include.my_variable', found in @liquid_context.scopes.first
    value ||= @page[name] if @page # Finds variables named like 'page.my_variable'
    value ||= dereference_include_variable(name)
    value ||= ''
    value
  end

  # Sets @params by replacing any Liquid variable names with their values
  def liquid_context=(context)
    @liquid_context = context
    @params = @keys_values.map { |k, _v| lookup_variable(k) }
  end

  def lookup_variable(symbol)
    if symbol.nil?
      puts "nil symbol"
    end
    string = symbol.to_s
    return string unless string.start_with?('{{') && string.end_with?('}}')

    dereference_variable(string.delete_prefix('{{').delete_suffix('}}'))
  end

  def page
    @liquid_context.registers[:page]
  end
end
