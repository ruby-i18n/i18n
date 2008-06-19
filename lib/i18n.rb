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
    
    def current_locale
      Thread.current[:locale] ||= default_locale
    end

    def current_locale=(locale)
      Thread.current[:locale] = locale
    end
    
    # Main translation method
    def translate(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}      
      options[:keys] = merge_keys options.delete(:scope), args.shift
      options[:locale] ||= args.shift

      backend.translate options
    end        
    alias :t :translate    
    
    def localize(*args)
      backend.localize(*args)
    end
    
  protected

    def merge_keys(scope, key)
      keys = []
      keys += scope.is_a?(Array) ? scope : scope.to_s.split(/\./) if scope
      keys += key.is_a?(Array) ? key : key.to_s.split(/\./)
      keys.map{|key| key.to_sym}
    end
  end
end


