require 'i18n/core_ext'
require 'i18n/backend/simple'

module I18n
  @@backend = Backend::Simple
  @@default_locale = 'en-US'
  
  class << self
    # Returns the current backend. Defaults to Backend::Simple.
    def backend
      @@backend
    end
    
    # Sets the current backend. Used to set a custom backend.
    def backend=(backend) 
      @@backend = backend
    end
  
    # Returns the current default locale. Defaults to 'en-US'
    def default_locale
      @@default_locale 
    end
    
    # Sets the current default locale. Used to set a custom default locale.
    def default_locale=(locale) 
      @@default_locale = locale 
    end
    
    # Returns the current locale. Defaults to I18n.default_locale.
    def locale
      Thread.current[:locale] ||= default_locale
    end

    # Sets the current locale pseudo-globally, i.e. in the Thread.current hash.
    def locale=(locale)
      Thread.current[:locale] = locale
    end
    
    # Translates, pluralizes and interpolates a given key using a given locale, 
    # scope, default as well as interpolation values.
    #
    # LOOKUP
    #
    # Translation data is organized as a nested hash using the locales as toplevel
    # keys. Upper-level keys can be used as namespaces. E.g. ActionView ships with
    # the translation: :'en-US' => {:date => {:formats => {:short => "%b %d"}}}
    # 
    # Translations can be looked up at any level of this hash using the key argument 
    # and the scope option. E.g., in this example :date.t 'en-US' returns the whole 
    # translations hash {:formats => {:short => "%b %d"}}
    # 
    # Key can be either a single key or a dot-separated key (both Strings and Symbols 
    # work). E.g. the short format can be looked up using both of:
    # 'date.formats.short'.t 'en-US'
    # :'date.formats.short'.t 'en-US'
    # 
    # Scope can be either a single key, a dot-separated key or an array of keys
    # or dot-separated keys. Keys and scopes can be combined freely. So these
    # examples will all look up the same short date format:
    # 'date.formats.short'.t 'en-US'
    # 'formats.short'.t 'en-US', :scope => 'date'
    # 'short'.t 'en-US', :scope => 'date.formats'
    # 'short'.t 'en-US', :scope => %w(date formats)
    #
    # INTERPOLATION
    #
    # Translations can contain interpolation variables which will be replaced by
    # values passed #translate as part of the options hash with the keys matching
    # the interpolation variable names. 
    #
    # E.g. with a translation :foo => "foo {{bar}}" the option value for the key 
    # bar will be interpolated to the translation:
    # :foo.t :bar => 'baz' # => 'foo baz'
    #
    # PLURALIZATION
    #
    # Translation data can contain pluralized translations. Pluralized translations
    # are arrays of singluar/plural versions of translations like ['Foo', 'Foos'].
    #
    # Note that the I18n::Backend::Simple only supports an algorithm for English 
    # pluralization rules. Other algorithms can be supported by custom backends.
    #
    # Returns the singular version of a pluralized translation:
    # :foo, :count => 1 # => 'Foo'
    #
    # Both return the plural version of a pluralized translation:
    # :foo, :count => 0 # => 'Foos'
    # :foo, :count => 2 # => 'Foos'
    # 
    # The :count option can be used both for pluralization and interpolation. E.g. 
    # with the translation :foo => ['{{count}} foo', '{{count}} foos'] count will
    # be interpolated to the pluralized translation:
    # :foo, :count => 1 # => '1 foo'
    #
    # DEFAULTS
    #
    # Returns the translation for :foo or 'default' if no translation was found.
    # :foo.t :default => 'default'
    #
    # Returns the translation for :foo or the translation for :bar if no 
    # translation for :foo was found.
    # :foo.t :default => :bar
    #
    # Returns the translation for :foo or the translation for :bar or 'default' if
    # no translations for :foo and :bar were found.
    # :foo.t :default => [:bar, 'default']
    #
    # BULK LOOKUP
    #
    # Returns an array with the translations for :foo and :bar.
    # I18n.t [:foo, :bar]
    #
    # Can be used with dot-separated nested keys:
    # I18n.t [:'baz.foo', :'baz.bar']
    #
    # Which is the same as using a scope option:
    # I18n.t [:foo, :bar], :scope => :baz
    def translate(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}      
      key = args.shift
      locale = args.shift || options.delete(:locale) || I18n.locale
      backend.translate key, locale, options
    end        
    alias :t :translate
    
    def localize(object, locale = nil, format = :default)
      locale ||= I18n.locale
      backend.localize(object, locale, format)
    end
    alias :l :localize
  end
end


