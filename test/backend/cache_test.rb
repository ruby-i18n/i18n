require 'test_helper'

begin
  require 'active_support'
rescue LoadError
  $stderr.puts "Skipping cache tests using ActiveSupport"
else

class I18nBackendCacheTest < Test::Unit::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Cache
  end

  def setup
    I18n.backend = Backend.new
    super
    I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)
  end

  def teardown
    I18n.cache_store = nil
    I18n.backend.send(:clear_cached_keys)
  end

  test "it uses the cache" do
    assert I18n.cache_store.is_a?(ActiveSupport::Cache::MemoryStore)
  end

  test "translate hits the backend and caches the response" do
    I18n.backend.expects(:lookup).returns('Foo')
    assert_equal 'Foo', I18n.t(:foo)

    I18n.backend.expects(:lookup).never
    assert_equal 'Foo', I18n.t(:foo)

    I18n.backend.expects(:lookup).returns('Bar')
    assert_equal 'Bar', I18n.t(:bar)
  end

  test "still raises MissingTranslationData but also caches it" do
    I18n.backend.expects(:lookup).returns(nil)
    assert_raise(I18n::MissingTranslationData) { I18n.t(:missing, :raise => true) }

    I18n.cache_store.expects(:write).never
    I18n.backend.expects(:lookup).never
    assert_raise(I18n::MissingTranslationData) { I18n.t(:missing, :raise => true) }
  end

  test "uses 'i18n' as a cache key namespace by default" do
    assert_equal 0, I18n.backend.send(:cache_key, :en, :foo, {}).index('i18n')
  end

  test "adds a custom cache key namespace" do
    with_cache_namespace('bar') do
      assert_equal 0, I18n.backend.send(:cache_key, :en, :foo, {}).index('i18n/bar/')
    end
  end

  test "adds locale and hash of key and hash of options" do
    options = { :bar=>1 }
    options_hash = I18n::Backend::Cache::USE_INSPECT_HASH ? options.inspect.hash : options.hash
    assert_equal "i18n//en/#{:foo.hash}/#{options_hash}", I18n.backend.send(:cache_key, :en, :foo, options)
  end

  test "keys should not be equal" do
    interpolation_values1 = { :foo => 1, :bar => 2 }
    interpolation_values2 = { :foo => 2, :bar => 1 }

    key1 = I18n.backend.send(:cache_key, :en, :some_key, interpolation_values1)
    key2 = I18n.backend.send(:cache_key, :en, :some_key, interpolation_values2)

    assert key1 != key2
  end

  test "adds cached key to list of cached keys" do
    I18n.backend.expects(:lookup).returns('Foo')
    I18n.t(:foo)
    assert I18n.backend.send(:cached_keys).include?(I18n.backend.send(:cache_key, :en, :foo, {}))
  end

  test "adds cached key only once" do
    I18n.backend.expects(:lookup).returns('Foo')
    I18n.t(:foo)
    I18n.t(:foo)

    assert_equal 1, I18n.backend.send(:cached_keys).length
  end

  test "adds cached key to list of cached keys with options" do
    I18n.backend.expects(:lookup).returns('Foo')
    I18n.t(:foo, :default => "bar")
    assert I18n.backend.send(:cached_keys).include?(I18n.backend.send(:cache_key, :en, :foo, {:default => "bar"}))
  end

  test "adds cached key to list of cached keys even if exception" do
    I18n.backend.expects(:lookup).returns(nil)
    begin
      I18n.t(:foo)
    rescue
    end
    assert I18n.backend.send(:cached_keys).include?(I18n.backend.send(:cache_key, :en, :foo, {}))
  end

  test "does not return cached value after cache is cleared" do
    I18n.backend.expects(:lookup).returns('Foo')
    I18n.t(:foo)
    I18n.backend.clear_cache

    assert_equal 0, I18n.backend.send(:cached_keys).length
    I18n.backend.expects(:lookup).returns('Bar')
    assert_equal 'Bar', I18n.t(:foo)
  end

  test "store_translations clears cache" do
    I18n.backend.expects(:lookup).returns('Foo')
    I18n.t(:foo)
    begin
      I18n.backend.store_translations(:en, nil)
    rescue
    end

    assert_equal 0, I18n.backend.send(:cached_keys).length
    I18n.backend.expects(:lookup).returns('Bar')
    assert_equal 'Bar', I18n.t(:foo)
  end

  protected

    def with_cache_namespace(namespace)
      I18n.cache_namespace = namespace
      yield
      I18n.cache_namespace = nil
    end
end

end # AS cache check
