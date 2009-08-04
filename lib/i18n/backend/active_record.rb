require 'i18n/backend/base'
require 'i18n/backend/active_record/translation'

module I18n
  module Backend
    class ActiveRecord < Base
      def reload!
      end

      def store_translations(locale, data)
        data.wind.each do |key, v|
          Translation.create(:locale => locale.to_s, :key => key, :value => v)
        end
      end

      def available_locales
        Translation.find(:all, :select => 'DISTINCT locale').map { |t| t.locale }
      end

      protected

        def lookup(locale, key, scope = [], separator = nil)
          return unless key

          separator ||= I18n.default_separator
          flat_key = (Array(scope) + Array(key)).join(separator)

          result = Translation.locale(locale).key(flat_key).find(:first)
          return result.value if result

          results = Translation.locale(locale).keys(flat_key, separator)
          if results.empty?
            return nil
          else
            chop_range = (flat_key.size + separator.size)..-1
            results = results.inject({}) do |hash, r|
              hash[r.key.slice(chop_range)] = hash[r.value]
              hash
            end
            deep_symbolize_keys(results)
          end
        end
    end
  end
end