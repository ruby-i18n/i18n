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


