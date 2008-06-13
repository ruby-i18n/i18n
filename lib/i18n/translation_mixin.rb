module I18n
  # This module should be mixed into every object that can be translated (where
  # the localization results into a string with pluralization and interpolation)
  module TranslationMixin
    # Main localization method
    def translate(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      
      options[:default] = args.shift if args.first.is_a? String
      key = args.shift || infer_localization_key_from_default(options[:default])

      options[:keys] = Array(options.delete(:scope)) << key
      options[:locale] ||= args.shift

      I18n.backend.translate typify_localization_options(options)
    end
        
    alias :t :translate
    
    protected
    
    def infer_localization_key_from_default(default)
      default.gsub(/ /, '_').gsub(/[\W]/, '').to_sym if default
    end
    
    # This method can be used by the object this module is mixed in to modify
    # the arguments (e.g. a symbol can specify itself as a key).
    def typify_localization_options(options)
      options
    end
  end
end