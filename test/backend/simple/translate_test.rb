# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class I18nSimpleBackendTranslateTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def test_translate_calls_lookup_with_locale_given
    @backend.expects(:lookup).with('de', :bar, [:foo], nil).returns 'bar'
    @backend.translate 'de', :bar, :scope => [:foo]
  end

  def test_given_no_keys_it_returns_the_default
    assert_equal 'default', @backend.translate('en', nil, :default => 'default')
  end

  def test_translate_given_a_symbol_as_a_default_translates_the_symbol
    assert_equal 'bar', @backend.translate('en', nil, :default => :'foo.bar')
  end

  def test_translate_default_with_scope_stays_in_scope_when_looking_up_the_symbol
    assert_equal 'bar', @backend.translate('en', :does_not_exist, :default => :bar, :scope => :foo)
  end

  def test_translate_given_an_array_as_default_uses_the_first_match
    assert_equal 'bar', @backend.translate('en', :does_not_exist, :scope => [:foo], :default => [:does_not_exist_2, :bar])
  end

  def test_translate_given_an_array_of_inexistent_keys_it_raises_missing_translation_data
    assert_raises I18n::MissingTranslationData do
      @backend.translate('en', :does_not_exist, :scope => [:foo], :default => [:does_not_exist_2, :does_not_exist_3])
    end
  end

  def test_translate_an_array_of_keys_translates_all_of_them
    assert_equal %w(bar baz), @backend.translate('en', [:bar, :baz], :scope => [:foo])
  end

  def test_translate_calls_pluralize
    @backend.expects(:pluralize).with 'en', 'bar', 1
    @backend.translate 'en', :bar, :scope => [:foo], :count => 1
  end

  def test_translate_calls_interpolate
    @backend.expects(:interpolate).with 'en', 'bar', {}
    @backend.translate 'en', :bar, :scope => [:foo]
  end

  def test_translate_calls_interpolate_including_count_as_a_value
    @backend.expects(:interpolate).with 'en', 'bar', {:count => 1}
    @backend.translate 'en', :bar, :scope => [:foo], :count => 1
  end

  def test_translate_given_nil_as_a_locale_raises_an_argument_error
    assert_raises(I18n::InvalidLocale){ @backend.translate nil, :bar }
  end

  def test_translate_with_a_bogus_key_and_no_default_raises_missing_translation_data
    assert_raises(I18n::MissingTranslationData){ @backend.translate 'de', :bogus }
  end
end

