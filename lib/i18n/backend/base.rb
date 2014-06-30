require 'yaml'
require 'i18n/core_ext/hash'
require 'i18n/core_ext/kernel/suppress_warnings'

module I18n
  module Backend
    module Base
      include I18n::Backend::Transliterator

      RESERVED_KEYS_HASH = RESERVED_KEYS.inject({}) do |h, reserved_key|
        h[reserved_key] = h[reserved_key.to_s.freeze] = true
        h
      end

      # Accepts a list of paths to translation files. Loads translations from
      # plain Ruby (*.rb) or YAML files (*.yml). See #load_rb and #load_yml
      # for details.
      def load_translations(*filenames)
        filenames = I18n.load_path if filenames.empty?
        filenames.flatten.each { |filename| load_file(filename) }
      end

      # This method receives a locale, a data hash and options for storing translations.
      # Should be implemented
      def store_translations(locale, data, options = {})
        raise NotImplementedError
      end

      def translate(locale, key, options = nil)
        raise InvalidLocale.new(locale) unless locale
        entry = key && lookup(locale, key, options && options[:scope], options)

        if options
          count   = options[:count]
          default = options[:default]
          entry   = nil == entry && default ?
            default(locale, key, default, options) : resolve(locale, key, entry, options)
        else
          entry = resolve(locale, key, entry, options)
        end

        unless nil == entry
          entry = entry.dup if entry.is_a?(String)
          entry = pluralize(locale, entry, count) if count
          entry = interpolate(locale, entry, options) if options
          entry
        end
      end

      def exists?(locale, key)
        lookup(locale, key) != nil
      end

      # Acts the same as +strftime+, but uses a localized version of the
      # format string. Takes a key from the date/time formats translations as
      # a format argument (<em>e.g.</em>, <tt>:short</tt> in <tt>:'date.formats'</tt>).
      def localize(locale, object, format = :default, options = {})
        raise ArgumentError, "Object must be a Date, DateTime or Time object. #{object.inspect} given." unless object.respond_to?(:strftime)

        if Symbol === format
          key  = format
          type = object.respond_to?(:sec) ? 'time' : 'date'
          options = options.merge(:raise => true, :object => object, :locale => locale)
          format  = I18n.t(:"#{type}.formats.#{key}", options)
        end

        # format = resolve(locale, object, format, options)
        format = format.to_s.gsub(/%[aAbBpP]/) do |match|
          case match
          when '%a' then I18n.t(:"date.abbr_day_names",                  :locale => locale, :format => format)[object.wday]
          when '%A' then I18n.t(:"date.day_names",                       :locale => locale, :format => format)[object.wday]
          when '%b' then I18n.t(:"date.abbr_month_names",                :locale => locale, :format => format)[object.mon]
          when '%B' then I18n.t(:"date.month_names",                     :locale => locale, :format => format)[object.mon]
          when '%p' then I18n.t(:"time.#{object.hour < 12 ? :am : :pm}", :locale => locale, :format => format).upcase if object.respond_to? :hour
          when '%P' then I18n.t(:"time.#{object.hour < 12 ? :am : :pm}", :locale => locale, :format => format).downcase if object.respond_to? :hour
          end
        end

        object.strftime(format)
      end

      # Returns an array of locales for which translations are available
      # ignoring the reserved translation meta data key :i18n.
      def available_locales
        raise NotImplementedError
      end

      def reload!
        @skip_syntax_deprecation = false
      end

      protected

        # The method which actually looks up for the translation in the store.
        def lookup(locale, key, scope = [], options = {})
          raise NotImplementedError
        end

        # Evaluates defaults.
        # If given subject is an Array, it walks the array and returns the
        # first translation that can be resolved. Otherwise it tries to resolve
        # the translation directly.
        def default(locale, object, subject, options = {})
          options = options.dup.reject { |key, value| key == :default }
          case subject
          when Array
            subject.each do |item|
              unless nil == (result = resolve(locale, object, item, options))
                return result
              end
            end and nil
          else
            resolve(locale, object, subject, options)
          end
        end

        # Resolves a translation.
        # If the given subject is a Symbol, it will be translated with the
        # given options. If it is a Proc then it will be evaluated. All other
        # subjects will be returned directly.
        def resolve(locale, object, subject, options = nil)
          return subject if options && options[:resolve] == false

          case subject
          when Symbol
            overrides = {:locale => locale, :exception_handler => DoNothingExceptionHandler}
            I18n.translate(subject, options ? options.merge(overrides) : overrides)
          when Proc
            date_or_time = (options && options.delete(:object)) || object
            resolve(locale, object, subject.call(date_or_time, options))
          else
            subject
          end
        end

        # Picks a translation from a pluralized mnemonic subkey according to English
        # pluralization rules :
        # - It will pick the :one subkey if count is equal to 1.
        # - It will pick the :other subkey otherwise.
        # - It will pick the :zero subkey in the special case where count is
        #   equal to 0 and there is a :zero subkey present. This behaviour is
        #   not stand with regards to the CLDR pluralization rules.
        # Other backends can implement more flexible or complex pluralization rules.
        def pluralize(locale, entry, count)
          return entry unless entry.is_a?(Hash) && count

          key = :zero if count == 0 && entry.has_key?(:zero)
          key ||= count == 1 ? :one : :other
          raise InvalidPluralizationData.new(entry, count) unless entry.has_key?(key)
          entry[key]
        end

        # Interpolates values into a given string.
        #
        #   interpolate "file %{file} opened by %%{user}", :file => 'test.txt', :user => 'Mr. X'
        #   # => "file test.txt opened by %{user}"
        def interpolate(locale, string, values = {})
          if string.is_a?(::String) && interpolation_values_any?(values)
            I18n.interpolate(string, values)
          else
            string
          end
        end

        def interpolation_values_any?(values)
          values.each_key do |key|
            return true if !RESERVED_KEYS_HASH[key]
          end
          false
        end

        # Loads a single translations file by delegating to #load_rb or
        # #load_yml depending on the file extension and directly merges the
        # data to the existing translations. Raises I18n::UnknownFileType
        # for all other file extensions.
        def load_file(filename)
          type = File.extname(filename).tr('.', '').downcase
          raise UnknownFileType.new(type, filename) unless respond_to?(:"load_#{type}", true)
          data = send(:"load_#{type}", filename)
          unless data.is_a?(Hash)
            raise InvalidLocaleData.new(filename, 'expects it to return a hash, but does not')
          end
          data.each { |locale, d| store_translations(locale, d || {}) }
        end

        # Loads a plain Ruby translations file. eval'ing the file must yield
        # a Hash containing translation data with locales as toplevel keys.
        def load_rb(filename)
          eval(IO.read(filename), binding, filename)
        end

        # Loads a YAML translations file. The data must have locales as
        # toplevel keys.
        def load_yml(filename)
          begin
            YAML.load_file(filename)
          rescue TypeError, ScriptError, StandardError => e
            raise InvalidLocaleData.new(filename, e.inspect)
          end
        end
    end
  end
end
