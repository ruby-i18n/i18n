require 'i18n/backend/simple'
require 'i18n/locale/fallbacks'

module I18n
  module Backend
    module Fallbacks
      def translate(locale, key, options = {})
        I18n.fallbacks[locale].each do |fallback|
          begin
            result = super(fallback, key, options) and return result
          rescue I18n::MissingTranslationData
          end
        end
        raise(I18n::MissingTranslationData.new(locale, key, options))
      end
    end
  end
end