require 'test_helper'

class I18nBackendJsonTest < Test::Unit::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::JSON
  end

  def setup
    I18n.backend = Backend.new
    I18n.load_path = [locales_dir + '/en.json']
  end

  test "json loads the translations from json files" do
    assert_equal "bar", I18n.t(:foo)
  end
end
