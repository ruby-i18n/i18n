# encoding: utf-8

module Tests
  module Api
    module Basics
      def teardown
        I18n.available_locales = nil
      end

      def test_available_locales
        store_translations('de', :foo => 'bar')
        store_translations('en', :foo => 'foo')

        assert I18n.available_locales.include?(:de)
        assert I18n.available_locales.include?(:en)
      end

      def test_available_locales_setter
        store_translations('de', :foo => 'bar')

        I18n.available_locales = :foo
        assert_equal [:foo], I18n.available_locales

        I18n.available_locales = [:foo, 'bar']
        assert_equal [:foo, :bar], I18n.available_locales

        I18n.available_locales = nil
        assert_equal [:de, :en], I18n.available_locales.sort {|a,b| a.to_s <=> b.to_s}
      end

      def test_available_locales_memoizes_when_explicitely_set
        I18n.backend.expects(:available_locales).never
        I18n.available_locales = [:foo]
        store_translations('de', :bar => 'baz')
        I18n.reload!
        assert_equal [:foo], I18n.available_locales
      end

      def test_available_locales_delegates_to_backend_when_not_explicitely_set
        I18n.backend.expects(:available_locales).twice
        assert_equal I18n.available_locales, I18n.available_locales
      end

      def test_delete_value
        store_translations(:to_be_deleted => 'bar')
        assert_equal 'bar', I18n.t('to_be_deleted', :default => 'baz')

        I18n.cache_store.clear if I18n.respond_to?(:cache_store) && I18n.cache_store
        store_translations(:to_be_deleted => nil)
        assert_equal 'baz', I18n.t('to_be_deleted', :default => 'baz')
      end
    end
  end
end
