#
#  This extension stores untranslated keys as translation stubs in the database. This is useful if you have a web based
#  translation tool. It will populate with untranslated keys as the application is being used. A translator can then go
#  through these. Example usage:
#
#     I18n::Backend::Chain.send(:include, I18n::Backend::ActiveRecordMissing)
#     I18n.backend = I18nChainBackend.new(I18n::Backend::ActiveRecord.new, I18n::Backend::Simple.new)
#
#  Stubs for pluralizations will also be created for each key defined in i18n.plural_keys. Eg:
#
#     en:
#       i18n:
#         plural_keys: [:zero, :one, :other]
#
#     pl:
#       i18n:
#         plural_keys: [:zero, :one, :few, :other]
#
#  This extension can also persist interpolation keys in Translation#interpolations. This is useful for translators
#  who cannot infer possible interpolations from the keys, as they can with other solutions such as gettext or globalize.
#
module I18n
  module Backend
    module ActiveRecordMissing

      def store_default_translations(locale, key, options = {})
        count, scope, default, separator = options.values_at(:count, *Base::RESERVED_KEYS)
        separator ||= I18n.default_separator
        keys = I18n.send(:normalize_translation_keys, locale, key, scope, separator)[1..-1]
        key = keys.join(separator || I18n.default_separator)

        unless ActiveRecord::Translation.locale(locale).lookup(key, separator).exists?
          interpolations = options.reject { |name, value| Base::RESERVED_KEYS.include?(name) }.keys
          keys = count ? I18n.t('i18n.plural_keys', :locale => locale).map { |k| [key, k].join(separator) } : [key]
          keys.each { |key| store_default_translation(locale, key, interpolations) } 
        end
      end

      def store_default_translation(locale, key, interpolations)
        translation = ActiveRecord::Translation.new :locale => locale.to_s, :key => key
        translation.interpolations = interpolations
        translation.save
      end
      
      def translate(locale, key, options = {})
        super

        rescue I18n::MissingTranslationData => e
          self.store_default_translations(locale, key, options)

          raise e
      end
    end
  end
end
