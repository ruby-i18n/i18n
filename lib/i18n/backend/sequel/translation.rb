require 'sequel'
require 'json'

module I18n
  module Backend
    # Sequel model used to store actual translations to the database.
    #
    # This model expects a table like the following to be already set up in
    # your the database:
    #
    #   create_table :i18n_translations do |t|
    #     String :locale, :null => false
    #     String :key, :null => false
    #     String :value, :text => true
    #     String :interpolations, :text => true
    #     TrueClass :is_proc, :null => false, :default => false
    #     primary_key [:locale, :key]
    #   end
    #
    # This model supports to named scopes :locale and :lookup. The :locale
    # scope simply adds a condition for a given locale:
    #
    #   I18n::Backend::Sequel::Translation.locale(:en).all
    #   # => all translation records that belong to the :en locale
    #
    # The :lookup scope adds a condition for looking up all translations
    # that either start with the given keys (joined by an optionally given
    # separator or I18n.default_separator) or that exactly have this key.
    #
    #   # with translations present for :"foo.bar" and :"foo.baz"
    #   I18n::Backend::Sequel::Translation.lookup(:foo)
    #   # => an array with both translation records :"foo.bar" and :"foo.baz"
    #
    #   I18n::Backend::Sequel::Translation.lookup([:foo, :bar])
    #   I18n::Backend::Sequel::Translation.lookup(:"foo.bar")
    #   # => an array with the translation record :"foo.bar"
    #
    # When the StoreProcs module was mixed into this model then Procs will
    # be stored to the database as Ruby code and evaluated when :value is
    # called.
    #
    #   Translation = I18n::Backend::Sequel::Translation
    #   Translation.create \
    #     :locale => 'en'
    #     :key    => 'foo'
    #     :value  => lambda { |key, options| 'FOO' }
    #   Translation.locale('en').lookup('foo').value
    #   # => 'FOO'
    class Sequel
      class Translation < ::Sequel::Model(:i18n_translations)
        TRUTHY_CHAR = "\001"
        FALSY_CHAR = "\002"

        unrestrict_primary_key
        set_restricted_columns :is_proc, :interpolations

        def_dataset_method(:locale) do |locale|
          filter(:locale => locale.to_s)
        end

        def_dataset_method(:lookup) do |keys, *separator|
          keys = Array(keys).map! { |key| key.to_s }

          unless separator.empty?
            warn "[DEPRECATION] Giving a separator to Translation.lookup is deprecated. " <<
              "You can change the internal separator by overwriting FLATTEN_SEPARATOR."
          end

          namespace = "#{keys.last}#{I18n::Backend::Flatten::FLATTEN_SEPARATOR}%"
          filter(:key => keys).or(:key.like(namespace))
        end

        plugin :serialization, :json, :value, :interpolations

        class << self
          def available_locales
            Translation.distinct.select(:locale).all.map { |t| t.locale.to_sym }
          end
        end

        def interpolates?(key)
          self.interpolations.include?(key) if self.interpolations
        end

        def value
          value = self[:value]
          if is_proc
            Kernel.eval(value)
          elsif value == FALSY_CHAR
            false
          elsif value == TRUTHY_CHAR
            true
          else
            value
          end
        end

        def value=(value)
          if value === false
            value = FALSY_CHAR
          elsif value === true
            value = TRUTHY_CHAR
          end

          write_attribute(:value, value)
        end
      end
    end
  end
end
