$:.unshift File.dirname(__FILE__)

module I18n
  @@default_locale = 'en-US'
  
  class << self
    def default_locale=(locale)
      @@default_locale = locale
    end
    
    def default_locale
      @@default_locale
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
      options[:keys] = I18n.merge_keys options.delete(:scope), args.shift
      options[:locale] ||= args.shift

      backend.translate options
    end        
    alias :t :translate    

    def merge_keys(scope, key)
      keys = []
      keys += scope.to_s.split(/\./) if scope
      keys += key.to_s.split(/\./)
      keys.map{|key| key.to_sym}
    end
  end
  
  @@backend = nil
  def self.backend; @@backend; end
  def self.backend=(new_val); @@backend = new_val; end
end

require 'i18n/core_ext'

