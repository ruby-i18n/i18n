# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'i18n/backend/fallbacks'

class I18nFallbacksBackendTest < Test::Unit::TestCase
  class Backend
    include I18n::Backend::Base
    include I18n::Backend::Fallbacks
  end

  def setup
    I18n.backend = Backend.new
    backend_store_translations(:en, :foo => 'Foo in :en', :bar => 'Bar in :en', :buz => 'Buz in :en')
    backend_store_translations(:de, :bar => 'Bar in :de', :baz => 'Baz in :de')
    backend_store_translations(:'de-DE', :baz => 'Baz in :de-DE')
  end

  define_method "test: still returns an existing translation as usual" do
    assert_equal 'Foo in :en', I18n.t(:foo, :locale => :en)
    assert_equal 'Bar in :de', I18n.t(:bar, :locale => :de)
    assert_equal 'Baz in :de-DE', I18n.t(:baz, :locale => :'de-DE')
  end

  define_method "test: returns the :en translation for a missing :de translation" do
    assert_equal 'Foo in :en', I18n.t(:foo, :locale => :de)
  end

  define_method "test: returns the :de translation for a missing :'de-DE' translation" do
    assert_equal 'Bar in :de', I18n.t(:bar, :locale => :'de-DE')
  end

  define_method "test: returns the :en translation for translation missing in both :de and :'de-De'" do
    assert_equal 'Buz in :en', I18n.t(:buz, :locale => :'de-DE')
  end

  define_method "test: raises I18n::MissingTranslationData exception when no translation was found" do
    assert_raises(I18n::MissingTranslationData) { I18n.t(:faa, :locale => :en, :raise => true) }
    assert_raises(I18n::MissingTranslationData) { I18n.t(:faa, :locale => :de, :raise => true) }
  end
end
