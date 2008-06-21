require 'i18n/core_ext'
require 'i18n/backend/simple'

module I18n
  @@backend = Backend::Simple
  @@default_locale = 'en-US'
  
  class << self
    def backend
      @@backend
    end
    
    def backend=(backend) 
      @@backend = backend
    end
  
    def default_locale
      @@default_locale 
    end
    
    def default_locale=(locale) 
      @@default_locale = locale 
    end
    
    def locale
      Thread.current[:locale] ||= default_locale
    end

    def locale=(locale)
      Thread.current[:locale] = locale
    end
    
    # Main translation method
    def translate(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}      
      key = args.shift
      locale = args.shift || options.delete(:locale) || I18n.locale      
      
      # merge dot separated key/scope and scope option,
      # use the first key from the merged scope as key if a key was given,
      # use the rest as scope unless empty
      scope = merge_keys options.delete(:scope), key
      key = scope.pop if key
      options[:scope] = scope unless scope.empty?      

      backend.translate key, locale, options
    end        
    alias :t :translate
    
    def localize(object, locale = nil, format = :default)
      locale ||= I18n.locale
      backend.localize(object, locale, format)
    end
    alias :l :localize
    
  protected

    def merge_keys(scope, key)
      keys = []
      keys += scope.is_a?(Array) ? scope : scope.to_s.split(/\./) if scope
      keys += key.to_s.split(/\./) unless key.is_a? Array
      keys.map{|key| key.to_sym}
    end
  end
end


