$:.unshift 'lib/i18n/lib'

require 'rubygems'
require 'mocha'
require 'test/unit'
require 'active_support'
require 'i18n'

class I18nTest < Test::Unit::TestCase
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
  
  def test_uses_default_locale_as_current_locale_by_default
    assert_equal I18n.default_locale, I18n.current_locale
  end
  
  def test_can_set_current_locale_to_thread_current
    assert_nothing_raised{ I18n.current_locale = 'de-DE' }
    assert_equal 'de-DE', I18n.current_locale
    assert_equal 'de-DE', Thread.current[:locale]
    I18n.current_locale = 'en-US'
  end
  
  def test_delegates_translate_to_backend
    I18n.backend.expects(:translate).with :foo, 'de-DE', {}
    I18n.translate :foo, 'de-DE'
  end
  
  def test_translate_given_no_locale_uses_i18n_current_locale
    I18n.backend.expects(:translate).with :foo, 'en-US', {}
    I18n.translate :foo
  end  
  
  def test_translate_on_nested_symbol_keys_works
    I18n.backend.expects(:translate).with(:precision, 'de-DE', :scope => [:currency, :format])
    I18n.t :'currency.format.precision', 'de-DE'
  end
  
  def test_translate_with_nested_string_keys_works
    I18n.backend.expects(:translate).with(:precision, 'de-DE', :scope => [:currency, :format])
    I18n.t 'currency.format.precision', 'de-DE'
  end
  
  # took these out to still have the option to decide to use Array#t for bulk lookup
  #
  # def test_translate_with_symbol_keys_array_works
  #   I18n.backend.expects(:translate).with(:locale => 'de-DE', :key => [:currency, :format, :precision])
  #   I18n.t [:currency, :format, :precision], 'de-DE'
  # end
  # 
  # def test_translate_with_string_keys_array_works
  #   I18n.backend.expects(:translate).with(:locale => 'de-DE', :key => [:currency, :format, :precision])
  #   I18n.t %w(currency format precision), 'de-DE'
  # end
  
  def test_translate_with_options_using_scope_works
    I18n.backend.expects(:translate).with(:precision, 'de-DE', :scope => [:currency, :format])
    I18n.with_options :locale => 'de-DE', :scope => :'currency.format' do |locale|
      locale.t :precision
    end
  end
  
  def test_delegates_localize_to_backend
    I18n.backend.expects(:localize).with(:whatever)
    I18n.localize :whatever
  end
end