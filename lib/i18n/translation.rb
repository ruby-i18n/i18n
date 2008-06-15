module I18n
  # This module should be mixed into every object that can be translated (where
  # the localization results into a string with pluralization and interpolation)
  module Translation
    # Main translation method
    def translate(*args)
      args = typify_localization_args(args)
      options = args.last.is_a?(Hash) ? args.pop : {}      
      options[:keys] = Array(options.delete(:scope)).dup << args.shift
      options[:locale] ||= args.shift

      I18n.backend.translate options
    end
        
    alias :t :translate
    
    protected
    
    # This method can be used by the object this module is mixed in to modify
    # the arguments (e.g. a symbol can specify itself as a key).
    def typify_localization_args(args)
      args
    end
  end
end