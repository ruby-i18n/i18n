# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class I18nSimpleBackendLoadTranslationsTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base

  def test_load_translations_with_unknown_file_type_raises_exception
    assert_raises(I18n::UnknownFileType) { I18n.backend.load_translations "#{locales_dir}/en.xml" }
  end

  def test_load_translations_with_ruby_file_type_does_not_raise_exception
    assert_nothing_raised { I18n.backend.load_translations "#{locales_dir}/en.rb" }
  end

  def test_load_rb_loads_data_from_ruby_file
    data = I18n.backend.send :load_rb, "#{locales_dir}/en.rb"
    assert_equal({ :en => { :fuh => { :bah => 'bas' } } }, data)
  end

  def test_load_rb_loads_data_from_yaml_file
    data = I18n.backend.send :load_yml, "#{locales_dir}/en.yml"
    assert_equal({ 'en' => { 'foo' => { 'bar' => 'baz' } } }, data)
  end

  def test_load_translations_loads_from_different_file_formats
    I18n.backend = I18n::Backend::Simple.new
    I18n.backend.load_translations "#{locales_dir}/en.rb", "#{locales_dir}/en.yml"
    expected = { :en => { :fuh => { :bah => "bas" }, :foo => { :bar => "baz" } } }
    assert_equal expected, backend_get_translations
  end
end

class I18nSimpleBackendStoreTranslationsTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base

  def test_store_translations_adds_translations # no, really :-)
    I18n.backend.store_translations :'en', :foo => 'bar'
    assert_equal Hash[:'en', {:foo => 'bar'}], backend_get_translations
  end

  def test_store_translations_deep_merges_translations
    I18n.backend.store_translations :'en', :foo => {:bar => 'bar'}
    I18n.backend.store_translations :'en', :foo => {:baz => 'baz'}
    assert_equal Hash[:'en', {:foo => {:bar => 'bar', :baz => 'baz'}}], backend_get_translations
  end

  def test_store_translations_forces_locale_to_sym
    I18n.backend.store_translations 'en', :foo => 'bar'
    assert_equal Hash[:'en', {:foo => 'bar'}], backend_get_translations
  end

  def test_store_translations_converts_keys_to_symbols
    # backend_reset_translations!
    I18n.backend.store_translations 'en', 'foo' => {'bar' => 'bar', 'baz' => 'baz'}
    assert_equal Hash[:'en', {:foo => {:bar => 'bar', :baz => 'baz'}}], backend_get_translations
  end
end

class I18nSimpleBackendReloadTranslationsTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base

  def setup
    I18n.backend = I18n::Backend::Simple.new
    I18n.load_path = [locales_dir + '/en.yml']
    assert_nil backend_get_translations
    I18n.backend.send :init_translations
  end

  def test_setup
    assert_not_nil backend_get_translations
  end

  def test_reload_translations_unloads_translations
    I18n.backend.reload!
    assert_nil backend_get_translations
  end

  def test_reload_translations_uninitializes_translations
    I18n.backend.reload!
    assert_equal I18n.backend.initialized?, false
  end
end
