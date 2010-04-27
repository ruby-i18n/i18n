# encoding: utf-8

# The Fast module contains optimizations that can tremendously speed up the
# lookup process on the Simple backend. It works by flattening the nested
# translation hash to a flat hash (e.g. { :a => { :b => 'c' } } becomes
# { :'a.b' => 'c' }).
#
# To enable these optimizations you can simply include the Fast module to
# the Simple backend:
#
#   I18n::Backend::Simple.send(:include, I18n::Backend::Fast)
module I18n
  module Backend
    module Fast
      include Links

      # Overwrite reload! to also clean up flattened translations.
      def reload!
        super
        reset_flattened_translations!
      end

      protected

        # Generate flattened translations after translations are initialized.
        def init_translations
          super
          flattened_translations
        end

        def flatten_translations(translations)
          # don't flatten locale roots
          translations.inject({}) do |result, (locale, translations)|
            result[locale] = wind_keys(translations, true)
            result[locale].each do |key, value|
              store_link(locale, key, value) if value.is_a?(Symbol)
            end
            result
          end
        end

        def lookup(locale, key, scope = nil, options = {})
          return unless key
          init_translations unless initialized?

          locale = locale.to_sym
          return nil unless flattened_translations[locale]

          # TODO Should link resolve locally or always globally?
          key = resolve_link(locale, key)

          keys = I18n.normalize_keys(locale, key, scope, options[:separator])
          key = keys[1..-1].map!{ |k| escape_default_separator(k) }.join(".").to_sym

          flattened_translations[locale][key]
        end

        # Store flattened translations in a variable.
        def flattened_translations
          @flattened_translations ||= flatten_translations(translations)
        end

        # Clean up flattened translations variable. Should be called whenever
        # the internal hash is changed.
        def reset_flattened_translations!
          @flattened_translations = nil
        end

        # Overwrite merge_translations to clean up the internal hash so added
        # translations are also cached.
        def merge_translations(locale, data, options = {})
          super
          reset_flattened_translations!
        end

    end
  end
end