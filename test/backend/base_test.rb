require 'test_helper'

class I18nBackendBaseTest < Test::Unit::TestCase
  include I18n::Backend::Base

  test "if YAML.load_file raises an exception, filepath info is prepended to the exception message" do
    invalid_file = "#{locales_dir}/invalid/syntax.yml"
    exception = assert_raise(Psych::SyntaxError) { load_translations(invalid_file) }
    assert_match(/^Error loading/, exception.message)
    assert_match(Regexp.new(File.expand_path(invalid_file)), exception.message)
    assert_match(/couldn't parse YAML/, exception.message)
  end
end
