module I18n
  module Backend
    class Chain < Base
      attr_accessor :backends

      def initialize(*backends)
        self.backends = backends
      end

      def reload!
        backends.each { |backend| backend.reload! }
      end

      def store_translations(locale, data)
        backends.first.store_translations(locale, data)
      end
      
      def available_locales
        backends.map { |backend| backend.available_locales }.flatten.uniq
      end

      # The implementation needs to be careful about the following I18n API
      # features:
      #
      # * defaults: never pass any default option to the backends but instead
      #   implement our own default mechanism (e.g. symbols as defaults would
      #   need to be passed to the whole chain to be translated).
      #
      # * namespace lookup: only return if the result is not a hash OR count
      #   is not present, otherwise merge them. So in effect the count variable
      #   would control whether we have a namespace lookup or a pluralization
      #   going on.
      #
      # * bulk translation: If the key is an array we need to call #translate
      #   for each of the keys and collect the results.
      #
      # * exceptions: Make sure that we catch MissingTranslationData exceptions
      #   and raise one in the end when no translation was found at all.
      def translate(locale, key, options = {})
        raise I18n::InvalidLocale.new(locale) if locale.nil?
        return key.map { |key| translate(locale, key, options) } if key.is_a?(Array)

        count, scope, default, separator = options.values_at(:count, *RESERVED_KEYS)
        values = options.reject { |name, value| RESERVED_KEYS.include?(name) }
        options.delete(:default)

        entry = backends.inject({}) do |namespace, backend|
          begin
            translation = backend.translate(locale.to_sym, key, options)
            if namespace_lookup?(translation, options)
              namespace.merge!(translation) 
            elsif !translation.nil?
              return translation
            end
          rescue I18n::MissingTranslationData
            namespace
          end
        end

        entry = entry.nil? || entry.empty? ? default(locale, key, default, options) : resolve(locale, key, entry, options)
        raise(I18n::MissingTranslationData.new(locale, key, options)) if entry.nil?
        entry = pluralize(locale, entry, count)
        entry = interpolate(locale, entry, values)
        entry
      end

      def localize(locale, object, format = :default)
        backends.each do |backend|
          result = backend.localize(locale, object, format) and return result
        end
      end

      protected

        def namespace_lookup?(entry, options)
          entry.is_a?(Hash) and not options.has_key?(:count)
        end
    end
  end
end