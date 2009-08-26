# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class I18nSimpleBackendApiBasicsTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Api::Basics

  def test_uses_simple_backend
    assert_equal I18n::Backend::Simple, I18n.backend.class
  end
end

class I18nSimpleBackendApiTranslateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Api::Translation

  # implementation specific tests
  
  def test_translate_calls_lookup_with_locale_given
    I18n.backend.expects(:lookup).with('de', :bar, [:foo], nil).returns 'bar'
    I18n.backend.translate 'de', :bar, :scope => [:foo]
  end

  def test_translate_calls_pluralize
    I18n.backend.expects(:pluralize).with 'en', 'bar', 1
    I18n.backend.translate 'en', :bar, :scope => [:foo], :count => 1
  end

  def test_translate_calls_interpolate
    I18n.backend.expects(:interpolate).with 'en', 'bar', {}
    I18n.backend.translate 'en', :bar, :scope => [:foo]
  end

  def test_translate_calls_interpolate_including_count_as_a_value
    I18n.backend.expects(:interpolate).with 'en', 'bar', {:count => 1}
    I18n.backend.translate 'en', :bar, :scope => [:foo], :count => 1
  end
end

class I18nSimpleBackendApiInterpolateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Api::Interpolation

  # implementation specific tests
  
  def test_interpolate_given_nil_as_a_string_returns_nil
    assert_nil I18n.backend.send(:interpolate, nil, nil, :name => 'David')
  end

  def test_interpolate_given_an_non_string_as_a_string_returns_nil
    assert_equal [], I18n.backend.send(:interpolate, nil, [], :name => 'David')
  end
end

class I18nSimpleBackendApiLambdaTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Api::Lambda
end

class I18nSimpleBackendApiTranslateLinkedTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Api::Link
end

class I18nSimpleBackendApiPluralizationTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Api::Pluralization
end

class I18nSimpleBackendApiLocalizeDateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Localization
  include Tests::Backend::Api::Localization::Date
end

class I18nSimpleBackendApiLocalizeDateTimeTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Localization
  include Tests::Backend::Api::Localization::DateTime
end

class I18nSimpleBackendApiLocalizeTimeTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Localization
  include Tests::Backend::Api::Localization::Time
end

class I18nSimpleBackendApiLocalizeLambdaTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Localization
  include Tests::Backend::Api::Localization::Lambda
end

