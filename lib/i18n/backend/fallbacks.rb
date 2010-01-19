# encoding: utf-8

# I18n locale fallbacks are useful when you want your application to use
# translations from other locales when translations for the current locale are
# missing. E.g. you might want to use :en translations when translations in
# your applications main locale :de are missing.
#
# To enable locale fallbacks you can simply include the Fallbacks module to
# the Simple backend - or whatever other backend you are using:
#
#   I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
module I18n
  @@fallbacks = nil

  class << self
    # Returns the current fallbacks implementation. Defaults to +I18n::Locale::Fallbacks+.
    def fallbacks
      @@fallbacks ||= I18n::Locale::Fallbacks.new
    end

    # Sets the current fallbacks implementation. Use this to set a different fallbacks implementation.
    def fallbacks=(fallbacks)
      @@fallbacks = fallbacks
    end
  end

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
      # The default option takes precedence over fallback locales
      # only when it's not a String. When default contains String it
      # is evaluated after fallback locales.
      #
      def translate(locale, key, options = {})
        if options[:default]
          string_default, options[:default] = Array[options[:default]].flatten.partition{|f| f.is_a?(String)}
        end
        for fallback in I18n.fallbacks[locale]
          begin
            result = super(fallback, key, options)
            return result unless result.nil?
          rescue I18n::MissingTranslationData
          end
        end
        super(locale, key, options.merge(:default => string_default)) || raise(I18n::MissingTranslationData.new(locale, key, options))
      end
    end
  end
end
