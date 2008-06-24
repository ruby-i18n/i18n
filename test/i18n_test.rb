$:.unshift "lib"

require 'rubygems'
require 'test/unit'
require 'mocha'
require 'i18n'
require 'active_support'

class I18nTest < Test::Unit::TestCase
  def setup
    I18n.backend.store_translations :'en-US', {
      :currency => {
        :format => {
          :separator => '.',
          :delimiter => ',',
        }
      }
    }
  end
  
  def test_uses_simple_backend_set_by_default
    assert_equal I18n::Backend::Simple, I18n.backend
  end
  
  def test_can_set_backend
    assert_nothing_raised{ I18n.backend = self }
    assert_equal self, I18n.backend
    I18n.backend = I18n::Backend::Simple
  end
  
  def test_uses_en_us_as_default_locale_by_default
    assert_equal 'en-US', I18n.default_locale
  end
  
  def test_can_set_default_locale
    assert_nothing_raised{ I18n.default_locale = 'de-DE' }
    assert_equal 'de-DE', I18n.default_locale
    I18n.default_locale = 'en-US'
  end
  
  def test_uses_default_locale_as_locale_by_default
    assert_equal I18n.default_locale, I18n.locale
  end
  
  def test_can_set_locale_to_thread_current
    assert_nothing_raised{ I18n.locale = 'de-DE' }
    assert_equal 'de-DE', I18n.locale
    assert_equal 'de-DE', Thread.current[:locale]
    I18n.locale = 'en-US'
  end
  
  def test_delegates_translate_to_backend
    I18n.backend.expects(:translate).with :foo, 'de-DE', {}
    I18n.translate :foo, 'de-DE'
  end
  
  def test_delegates_localize_to_backend
    I18n.backend.expects(:localize).with :whatever, 'de-DE', :default
    I18n.localize :whatever, 'de-DE'
  end
  
  def test_translate_given_no_locale_uses_i18n_locale
    I18n.backend.expects(:translate).with :foo, 'en-US', {}
    I18n.translate :foo
  end  
  
  def test_translate_on_nested_symbol_keys_works
    assert_equal ".", I18n.t(:'currency.format.separator', 'en-US')
  end
  
  def test_translate_with_nested_string_keys_works
    assert_equal ".", I18n.t('currency.format.separator', 'en-US')
  end
  
  def test_translate_with_array_as_scope_works
    assert_equal ".", I18n.t(:separator, 'en-US', :scope => ['currency.format'])
  end
  
  def test_translate_with_array_containing_dot_separated_strings_as_scope_works
    assert_equal ".", I18n.t(:separator, 'en-US', :scope => ['currency.format'])
  end
  
  def test_translate_with_key_array_and_dot_separated_scope_works
    assert_equal [".", ","], I18n.t(%w(separator delimiter), 'en-US', :scope => 'currency.format')
  end
  
  def test_translate_with_dot_separated_key_array_and_scope_works
    assert_equal [".", ","], I18n.t(%w(format.separator format.delimiter), 'en-US', :scope => 'currency')
  end
  
  def test_translate_with_options_using_scope_works
    I18n.backend.expects(:translate).with(:precision, 'de-DE', :scope => :"currency.format")
    I18n.with_options :locale => 'de-DE', :scope => :'currency.format' do |locale|
      locale.t :precision
    end
  end
  
  def test_translate_no_args
    assert_raises(ArgumentError) { I18n.t }
  end

  def test_localize_no_args
    assert_raises(ArgumentError) { I18n.l }
  end
  
  def test_translate_just_key
    assert_equal :bogus_key, I18n.t(:bogus_key)
  end

  def test_localize_nil
    assert_nil I18n.l(nil)
  end

  def test_localize_object
    obj = Object.new
    assert_equal obj, I18n.l(obj)
  end
end
