module I18n
  module Backend
    module Pluralization
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