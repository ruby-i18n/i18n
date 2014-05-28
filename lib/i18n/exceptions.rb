require 'cgi'

module I18n
  # Handles exceptions raised in the backend. All exceptions except for
  # MissingTranslationData exceptions are re-raised. When a MissingTranslationData
  # was caught the handler returns an error message string containing the key/scope.
  # Note that the exception handler is not called when the option :raise was given.
  class ExceptionHandler
    include Module.new {
      def call(exception, locale, key, options)
        if exception.is_a?(MissingTranslationData)
          #
          # TODO: this block is to be replaced by `exception.message` when
          # rescue_format is removed
          if options[:rescue_format] == :html
            if !defined?(@rescue_format_deprecation)
              $stderr.puts "[DEPRECATED] I18n's :recue_format option will be removed from a future release. All exception messages will be plain text. If you need the exception handler to return an html format please set or pass a custom exception handler."
              @rescue_format_deprecation = true
            end
            exception.html_message
          else
            exception.message
          end

        else
          raise exception
        end
      end
    }
  end

  class ArgumentError < ::ArgumentError; end

  class InvalidLocale < ArgumentError
    attr_reader :locale
    def initialize(locale)
      @locale = locale
      super "#{locale.inspect} is not a valid locale"
    end
  end

  class InvalidLocaleData < ArgumentError
    attr_reader :filename
    def initialize(filename)
      @filename = filename
      super "can not load translations from #{filename}, expected it to return a hash, but does not"
    end
  end

  class MissingTranslationData < ArgumentError
    attr_reader :locale, :key, :options

    def initialize(locale, key, opts = nil)
      @key, @locale, @options = key, locale, opts.dup || {}
      options.each { |k, v| options[k] = v.inspect if v.is_a?(Proc) }
      super "translation missing: #{keys.join('.')}"
    end

    def html_message
      key  = CGI.escapeHTML titleize(keys.last)
      path = CGI.escapeHTML keys.join('.')
      %(<span class="translation_missing" title="translation missing: #{path}">#{key}</span>)
    end

    def keys
      @keys ||= I18n.normalize_keys(locale, key, options[:scope]).tap do |keys|
        keys << 'no key' if keys.size < 2
      end
    end

    protected

    # TODO : remove when #html_message is removed
    def titleize(key)
      key.to_s.gsub('_', ' ').gsub(/\b('?[a-z])/) { $1.capitalize }
    end
  end

  class InvalidPluralizationData < ArgumentError
    attr_reader :entry, :count
    def initialize(entry, count)
      @entry, @count = entry, count
      super "translation data #{entry.inspect} can not be used with :count => #{count}"
    end
  end

  class MissingInterpolationArgument < ArgumentError
    attr_reader :values, :string
    def initialize(values, string)
      @values, @string = values, string
      super "missing interpolation argument in #{string.inspect} (#{values.inspect} given)"
    end
  end

  class ReservedInterpolationKey < ArgumentError
    attr_reader :key, :string
    def initialize(key, string)
      @key, @string = key, string
      super "reserved key #{key.inspect} used in #{string.inspect}"
    end
  end

  class UnknownFileType < ArgumentError
    attr_reader :type, :filename
    def initialize(type, filename)
      @type, @filename = type, filename
      super "can not load translations from #{filename}, the file type #{type} is not known"
    end
  end
end
