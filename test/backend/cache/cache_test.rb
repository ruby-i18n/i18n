require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'i18n/backend/cache'
require 'activesupport'

class I18nCacheBackendTest < Test::Unit::TestCase
  def setup
    super
    class << I18n.backend
      include I18n::Backend::Cache
    end
    I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)
  end
  
  def teardown
    I18n.cache_store = nil
  end
  
  define_method :"test translate hits the backend and caches the response" do
    I18n.backend.expects(:lookup).returns('Foo')
    assert_equal 'Foo', I18n.t(:foo)
    
    I18n.backend.expects(:lookup).never
    assert_equal 'Foo', I18n.t(:foo)
  
    I18n.backend.expects(:lookup).returns('Bar')
    assert_equal 'Bar', I18n.t(:bar)
  end
  
  define_method :"test still raises MissingTranslationData but also caches it" do
    I18n.backend.expects(:lookup).returns(nil)
    assert_raises(I18n::MissingTranslationData) { I18n.t(:missing, :raise => true) }
    I18n.backend.expects(:lookup).never
    assert_raises(I18n::MissingTranslationData) { I18n.t(:missing, :raise => true) }
  end
end
