# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class I18nSimpleBackendTranslationsTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def test_store_translations_adds_translations # no, really :-)
    @backend.store_translations :'en', :foo => 'bar'
    assert_equal Hash[:'en', {:foo => 'bar'}], backend_get_translations
  end

  def test_store_translations_deep_merges_translations
    @backend.store_translations :'en', :foo => {:bar => 'bar'}
    @backend.store_translations :'en', :foo => {:baz => 'baz'}
    assert_equal Hash[:'en', {:foo => {:bar => 'bar', :baz => 'baz'}}], backend_get_translations
  end

  def test_store_translations_forces_locale_to_sym
    @backend.store_translations 'en', :foo => 'bar'
    assert_equal Hash[:'en', {:foo => 'bar'}], backend_get_translations
  end

  def test_store_translations_converts_keys_to_symbols
    # backend_reset_translations!
    @backend.store_translations 'en', 'foo' => {'bar' => 'bar', 'baz' => 'baz'}
    assert_equal Hash[:'en', {:foo => {:bar => 'bar', :baz => 'baz'}}], backend_get_translations
  end
end

class I18nSimpleBackendAvailableLocalesTest < Test::Unit::TestCase
  def test_available_locales
    @backend = I18n::Backend::Simple.new
    @backend.store_translations 'de', :foo => 'bar'
    @backend.store_translations 'en', :foo => 'foo'

    assert_equal ['de', 'en'], @backend.available_locales.map{|locale| locale.to_s }.sort
  end
end

class I18nSimpleBackendHelperMethodsTest < Test::Unit::TestCase
  def setup
    @backend = I18n::Backend::Simple.new
  end

  def test_deep_symbolize_keys_works
    result = @backend.send :deep_symbolize_keys, 'foo' => {'bar' => {'baz' => 'bar'}}
    expected = {:foo => {:bar => {:baz => 'bar'}}}
    assert_equal expected, result
  end
end

class I18nSimpleBackendLoadTranslationsTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def test_load_translations_with_unknown_file_type_raises_exception
    assert_raises(I18n::UnknownFileType) { @backend.load_translations "#{@locale_dir}/en.xml" }
  end

  def test_load_translations_with_ruby_file_type_does_not_raise_exception
    assert_nothing_raised { @backend.load_translations "#{@locale_dir}/en.rb" }
  end

  def test_load_rb_loads_data_from_ruby_file
    data = @backend.send :load_rb, "#{@locale_dir}/en.rb"
    assert_equal({:'en-Ruby' => {:foo => {:bar => "baz"}}}, data)
  end

  def test_load_rb_loads_data_from_yaml_file
    data = @backend.send :load_yml, "#{@locale_dir}/en.yml"
    assert_equal({'en-Yaml' => {'foo' => {'bar' => 'baz'}}}, data)
  end

  def test_load_translations_loads_from_different_file_formats
    @backend = I18n::Backend::Simple.new
    @backend.load_translations "#{@locale_dir}/en.rb", "#{@locale_dir}/en.yml"
    expected = {
      :'en-Ruby' => {:foo => {:bar => "baz"}},
      :'en-Yaml' => {:foo => {:bar => "baz"}}
    }
    assert_equal expected, backend_get_translations
  end
end

class I18nSimpleBackendLoadPathTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def teardown
    I18n.load_path = []
  end

  def test_nested_load_paths_do_not_break_locale_loading
    @backend = I18n::Backend::Simple.new
    I18n.load_path = [[File.dirname(__FILE__) + '/../../locale/en.yml']]
    assert_nil backend_get_translations
    assert_nothing_raised { @backend.send :init_translations }
    assert_not_nil backend_get_translations
  end

  def test_adding_arrays_of_filenames_to_load_path_do_not_break_locale_loading
    @backend = I18n::Backend::Simple.new
    I18n.load_path << Dir[File.dirname(__FILE__) + '/../../locale/*.{rb,yml}']
    assert_nil backend_get_translations
    assert_nothing_raised { @backend.send :init_translations }
    assert_not_nil backend_get_translations
  end
end

class I18nSimpleBackendReloadTranslationsTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def setup
    @backend = I18n::Backend::Simple.new
    I18n.load_path = [File.dirname(__FILE__) + '/../../locale/en.yml']
    assert_nil backend_get_translations
    @backend.send :init_translations
  end

  def teardown
    I18n.load_path = []
  end

  def test_setup
    assert_not_nil backend_get_translations
  end

  def test_reload_translations_unloads_translations
    @backend.reload!
    assert_nil backend_get_translations
  end

  def test_reload_translations_uninitializes_translations
    @backend.reload!
    assert_equal @backend.initialized?, false
  end
end
