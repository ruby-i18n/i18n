# encoding: utf-8

# This module allows you to easily cache all responses from the backend - thus
# speeding up the I18n aspects of your application quite a bit.
#
# To enable caching you can simply include the Cache module to the Simple
# backend - or whatever other backend you are using:
#
#  I18n::Backend::Simple.send(:include, I18n::Backend::Cache)
#
# You will also need to set a cache store implementation that you want to use:
#
#  I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)
#
# You can use any cache implementation you want that provides the same API as
# ActiveSupport::Cache (only the methods #fetch and #write are being used).
#
# The cache_key implementation assumes that you only pass values to
# I18n.translate that return a valid key from #hash (see
# http://www.ruby-doc.org/core/classes/Object.html#M000337).
module I18n
  class << self
    @@cache_store = nil
    @@cache_namespace = nil

    def cache_store
      @@cache_store
    end

    def cache_store=(store)
      @@cache_store = store
    end

    def cache_namespace
      @@cache_namespace
    end

    def cache_namespace=(namespace)
      @@cache_namespace = namespace
    end

    def perform_caching?
      !cache_store.nil?
    end
  end

  module Backend
    module Cache
      def translate(*args)
        I18n.perform_caching? ? fetch(*args) { super } : super
      end

      protected

        def fetch(*args, &block)
          result = I18n.cache_store.fetch(cache_key(*args), &block)
          raise result if result.is_a?(Exception)
          result
        rescue MissingTranslationData => exception
          I18n.cache_store.write(cache_key(*args), exception)
          raise exception
        end

        def cache_key(*args)
          # this assumes that only simple, native Ruby values are passed to I18n.translate
          keys = ['i18n', I18n.cache_namespace, args.hash]
          keys.compact.join('-')
        end
    end
  end
end