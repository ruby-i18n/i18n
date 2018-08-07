require 'test_helper'

class I18nFallbacksApiTest < I18n::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Fallbacks
  end

  def setup
    I18n.backend = Backend.new
    super
  end

  include I18n::Tests::Basics
  include I18n::Tests::Defaults
  include I18n::Tests::Interpolation
  include I18n::Tests::Link
  include I18n::Tests::Lookup
  include I18n::Tests::Pluralization
  include I18n::Tests::Procs
  include I18n::Tests::Localization::Date
  include I18n::Tests::Localization::DateTime
  include I18n::Tests::Localization::Time
  include I18n::Tests::Localization::Procs

  test "fallback does not work with defaults when using en-CH locale" do
    I18n.with_locale(:'en-CH') do
      assert_equal 'i exist', I18n.t(:faa)
      assert_equal 'i exist', I18n.t(:faa, :default => [:'foo.bar'])
    end
  end

  test "fallback works with defaults when using en locale" do
    I18n.with_locale(:en) do
      assert_equal 'i exist', I18n.t(:faa)
      assert_equal 'i exist', I18n.t(:faa, :default => [:'foo.bar'])
    end
  end

  test "make sure we use a backend with Fallbacks included" do
    assert_equal Backend, I18n.backend.class
  end

  # links: test that keys stored on one backend can link to keys stored on another backend
end
