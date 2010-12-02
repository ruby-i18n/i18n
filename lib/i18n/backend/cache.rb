# This module allows you to easily cache all responses from the backend - thus
# speeding up the I18n aspects of your application quite a bit.
#
# To enable caching you can simply include the Cache module to the Simple
# backend - or whatever other backend you are using:
#
#   I18n::Backend::Simple.send(:include, I18n::Backend::Cache)
#
# You will also need to set a cache store implementation that you want to use:
#
#   I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)
#
# You can use any cache implementation you want that provides the same API as
# ActiveSupport::Cache (only the methods #fetch, #write and #delete are being
# used).
#
# The cache_key implementation assumes that you only pass values to
# I18n.translate that return a valid key from #hash (see
# http://www.ruby-doc.org/core/classes/Object.html#M000337).
#
# If you use a lambda as a default value in your translation like this:
#
#   I18n.t(:"date.order", :default => lambda {[:month, :day, :year]})
#
# Then you will always have a cache miss, because each time this method
# is called the lambda will have a different hash value. If you know
# the result of the lambda is a constant as in the example above, then
# to cache this you can make the lambda a constant, like this:
#
#   DEFAULT_DATE_ORDER = lambda {[:month, :day, :year]}
#   ...
#   I18n.t(:"date.order", :default => DEFAULT_DATE_ORDER)
#
# If the lambda may result in different values for each call then consider
# also using the Memoize backend.
#
# The implementation keeps a list of cached keys, and deletes these keys from
# the cache store whenever new translations are stored using the
# #store_translations method. YMMV performance-wise with a large number of
# cached keys.
#
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
      @@cached_keys = []

      def store_translations(locale, data, options = {})
        clear_cache if I18n.perform_caching?
        super
      end

      def translate(locale, key, options = {})
        I18n.perform_caching? ? fetch(cache_key(locale, key, options)) { super } : super
      end

      def clear_cache
        @@cached_keys.each do |key|
          I18n.cache_store.delete(key)
        end

        clear_cached_keys
      end

      protected

        def fetch(cache_key, &block)
          result = fetch_storing_missing_translation_exception(cache_key, &block)
          raise result if result.is_a?(Exception)
          result = result.dup if result.frozen? rescue result
          result
        end

        def fetch_storing_missing_translation_exception(cache_key, &block)
          fetch_ignoring_procs(cache_key, &block)
        rescue MissingTranslationData => exception
          I18n.cache_store.write(cache_key, exception)
          add_cached_key(cache_key)
          exception
        end

        def fetch_ignoring_procs(cache_key, &block)
          I18n.cache_store.read(cache_key) || yield.tap do |result|
            unless result.is_a?(Proc)
              I18n.cache_store.write(cache_key, result)
              add_cached_key(cache_key)
            end
          end
        end

        def cache_key(locale, key, options)
          # This assumes that only simple, native Ruby values are passed to I18n.translate.
          "i18n/#{I18n.cache_namespace}/#{locale}/#{key.hash}/#{USE_INSPECT_HASH ? options.inspect.hash : options.hash}"
        end

        def cached_keys
          @@cached_keys
        end

        def add_cached_key(cache_key)
          @@cached_keys << cache_key if !@@cached_keys.include?(cache_key)
        end

        def clear_cached_keys
          @@cached_keys = []
        end

      private
        # In Ruby < 1.9 the following is true: { :foo => 1, :bar => 2 }.hash == { :foo => 2, :bar => 1 }.hash
        # Therefore we must use the hash of the inspect string instead to avoid cache key colisions.
        USE_INSPECT_HASH = RUBY_VERSION <= "1.9"
    end
  end
end
