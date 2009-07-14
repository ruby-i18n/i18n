require 'i18n/locale/fallbacks'

module I18n
  module Backend
    module Fallbacks
      # Overwrites the Base backend translate method so that it will try each
      # locale given by I18n.fallbacks for the given locale. E.g. for the
      # locale :"de-DE" it might try the locales :"de-DE", :de and :en
      # (depends on the fallbacks implementation) until it finds a result with
      # the given options. If it does not find any result for any of the
      # locales it will then raise a MissingTranslationData exception as
      # usual.
      #
      # The default option takes precedence over fallback locales, i.e. it
      # will first evaluate a given default option before falling back to
      # another locale.
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