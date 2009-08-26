# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'i18n/backend/fallbacks'

class I18nFallbacksBackendTest < Test::Unit::TestCase
  def setup
    I18n.backend = I18n::Backend::Simple.new
    I18n.backend.meta_class.send(:include, I18n::Backend::Fallbacks)
    backend_store_translations(:en, :foo => 'Foo')
  end

  define_method "test: fallbacks for :de are [:de, :en]" do
    assert_equal [:de, :en], I18n.fallbacks[:de]
  end
  
  define_method "test: still returns the English translation as usual" do
    assert_equal 'Foo', I18n.t(:foo, :locale => :en)
  end
  
  define_method "test: returns the English translation for a missing German translation" do
    assert_equal 'Foo', I18n.t(:foo, :locale => :de)
  end
  
  define_method "test: raises I18n::MissingTranslationData exception when no translation was found" do
    assert_raises(I18n::MissingTranslationData) { I18n.t(:bar, :locale => :en, :raise => true) }
    assert_raises(I18n::MissingTranslationData) { I18n.t(:bar, :locale => :de, :raise => true) }
  end
end