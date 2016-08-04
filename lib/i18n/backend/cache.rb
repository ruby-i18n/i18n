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
# ActiveSupport::Cache (only the methods #fetch and #write are being used).
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

    def cache_keys
      @@cache_keys ||= Backend::Cache::Keys.new
    end

    def perform_caching?
      !cache_store.nil?
    end
  end

  module Backend
    module Cache
      class Keys
        def add(locale, key, options)
          keys = cache_keys
          keys[[locale, key]] ||= Set.new
          keys[[locale, key]] << options
          update(keys)
        end

        def delete(locale, keys)
          ckeys = cache_keys
          keys.each {|k| ckeys.delete([locale, k])}
          update(ckeys)
        end

        def delete_all
          update({})
        end

        def [](locale, key)
          cache_keys[[locale, key]] || Set.new
        end

        def all
          cache_keys
        end

        protected

          def cache_keys
            result = I18n.cache_store.read("i18n/#{I18n.cache_namespace}/cache_keys")
            if result
              Marshal.load(StringIO.new(result))
            else
              {}
            end
          end

          def update(cache_keys)
            I18n.cache_store.write("i18n/#{I18n.cache_namespace}/cache_keys", Marshal.dump(cache_keys))
          end
      end

      include Flatten

      def reload!
        delete_all_keys_from_cache if I18n.perform_caching?
        super
      end

      def translate(locale, key, options = {})
        I18n.perform_caching? ? fetch(locale, key, options) { super } : super
      end

      def store_translations(locale, data, options = {})
        delete_keys_from_cache(locale, data, options) if I18n.perform_caching?
        super
      end

      protected

        def fetch(locale, key, options, &block)
          result = _fetch(locale, key, options, &block)
          throw(:exception, result) if result.is_a?(MissingTranslation)
          result = result.dup if result.frozen? rescue result
          result
        end

        def _fetch(locale, key, options, &block)
          cache_key = cache_key(locale, key, options)
          result = I18n.cache_store.read(cache_key) and return result
          result = catch(:exception, &block)
          unless result.is_a?(Proc) || options.values.any? {|v| v.is_a?(Proc)}
            I18n.cache_store.write(cache_key, result)
            I18n.cache_keys.add(locale, key, options)
          end
          result
        end

        def delete_all_keys_from_cache
          I18n.cache_keys.all.keys.each do |locale, key|
            delete_from_cache(locale, key)
          end

          I18n.cache_keys.delete_all
        end

        def delete_keys_from_cache(locale, data, options)
          escape = options.fetch(:escape, true)
          keys = flatten_translations(locale, data, escape, false).keys
          keys.each do |key|
            delete_from_cache(locale, key)
          end

          I18n.cache_keys.delete(locale, keys)
        end

        def delete_from_cache(locale, key)
          I18n.cache_keys[locale, key].each do |options|
            I18n.cache_store.delete(cache_key(locale, key, options))
          end
        end

        def cache_key(locale, key, options)
          # This assumes that only simple, native Ruby values are passed to I18n.translate.
          "i18n/#{I18n.cache_namespace}/#{locale}/#{key.hash}/#{USE_INSPECT_HASH ? options.inspect.hash : options.hash}"
        end

      private
        # In Ruby < 1.9 the following is true: { :foo => 1, :bar => 2 }.hash == { :foo => 2, :bar => 1 }.hash
        # Therefore we must use the hash of the inspect string instead to avoid cache key colisions.
        USE_INSPECT_HASH = RUBY_VERSION <= "1.9"
    end
  end
end
