module I18n
  module Backend
    module Pluralization
      # Overwrites the Base backend translate method so that it will check the
      # translation meta data space (:i18n) for locale specific pluralizers
      # and use them to pluralize the given entry.
      #
      # Pluralizers are expected to respond to #call(entry, count) and return
      # a pluralization key. Valid keys depend on the translation data hash
      # (entry) but it is generally recommended to follow CLDR's style, i.e.
      # return one of the keys :zero, :one, :few, :many, :other.
      #
      # The :zero key is always picked directly when count equals 0 AND the
      # translation data has the key :zero. This way translators are free to
      # either pick a special :zero translation even for languages where the
      # pluralizer does not return a :zero key.
      def pluralize(locale, entry, count)
        return entry unless entry.is_a?(Hash) and count

        pluralizer = pluralizer(locale)
        if pluralizer.respond_to?(:call)
          key = count == 0 && entry.has_key?(:zero) ? :zero : pluralizer.call(count)
          raise InvalidPluralizationData.new(entry, count) unless entry.has_key?(key)
          entry[key]
        else
          super
        end
      end

      protected

        def pluralizers
          @pluralizers ||= {}
        end

        def pluralizer(locale)
          pluralizers[locale] ||= lookup(locale, :"i18n.pluralize")
        end
    end
  end
end