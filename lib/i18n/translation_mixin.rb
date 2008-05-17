require 'strscan'

module I18n
  class MissingInterpolationKeyError < ArgumentError; end
  
  @@raise_exceptions = true
  def self.raise_exceptions; @@raise_exceptions; end
  def self.raise_exceptions=(new_val); @@raise_exceptions = new_val; end
  
  @@backend = nil
  def self.backend; @@backend; end
  def self.backend=(new_val); @@backend = new_val; end  
  
  # This module should be mixed into every object that can be translated (where
  # the localization results into a string with pluralization and interpolation)
  module TranslationMixin
    # Main localization method
    # 
    # The method supports an explicit/long form and a implicit/short form. See
    # parse_args_by_keys and parse_args_by_type for details.
    # 
    # The arguments will be modified depending on the target object. If the
    # target object is a string and no default value is specified the string
    # value is used as a default value. If it's a symbol its value is appended
    # to the keys array resulting in a nested key.    
    def localize(*args)
      options = explicit_options?(args.last) ? parse_args_by_keys(args.last) : parse_args_by_type(*args)
      options = typify_localization_options(options)
      check_options!(options)
      
      entry = I18n.backend.lookup(options[:keys]) if I18n.backend.respond_to? :lookup
      entry = I18n.backend.pluralize(entry, options[:plural]) if entry && options[:plural] && I18n.backend.respond_to?(:pluralize)
      entry = options[:default] unless entry
      (options[:values] ||= {}).update({:count => options[:plural]}) if entry && options[:plural]
      entry = (I18n.backend.respond_to?(:interpolate) ?
                 I18n.backend.interpolate(entry, options[:values]) :
                 self.interpolate(entry, options[:values])) if entry && options[:values]
      
      entry
    end
    
    alias :l :localize
    
    protected
    
    # Tests if the method is used with its explicit signature by testing for
    # "reserved" key names (:key, :default, :values, :plural or :scope)
    def explicit_options?(options)
      options.kind_of?(Hash) and [:key, :default, :values, :plural, :scope].any? { |key| options.has_key? key }
    end
    
    # Parses the options when the explicit method signature is used.
    def parse_args_by_keys(options)
      { :keys => Array(options[:scope]) + Array(options[:key]),
        :default => options[:default],
        :plural => options[:plural],
        :values => options[:values]
      }
    end
    
    # Parses the options when the implicit method signature is used. This
    # detects the arguments by their type:
    # 
    # - Symbols will be used as keys (multiple as nested keys).
    # - The first string found is used as default value.
    # - The first number (Numeric) found will be used as pluralization count.
    # - The first hash is used for interpolation.
    def parse_args_by_type(*args)
      { :keys => args.select { |arg| arg.kind_of?(Symbol) },
        :default => args.detect { |arg| arg.kind_of?(String) },
        :plural => args.detect { |arg| arg.kind_of?(Numeric) },
        :values => args.detect { |arg| arg.kind_of?(Hash) }
      }
    end
    
    # Checks if all requirements for calling the localize method are satisfied
    # and raises an ArgumentError if not.
    def check_options!(options)
      keys, default, plural, values = options[:keys], options[:default], options[:plural], options[:values]
      unless ( keys.empty? or keys.all?{|key| key.kind_of?(Symbol)} ) and
             ( default.nil? or default.kind_of?(String) ) and
             ( plural.nil? or plural.kind_of?(Numeric) ) and
             ( values.nil? or values.kind_of?(Hash) )
        raise ArgumentError, "It seemed like you used an reserved option (:key, :default, :values, " +
          ":plural and :scope) as an interpolation key. Please use another name for this interpolation " +
          "key or escape is as a string (e.g. 'values' => 'something' instead of :values => 'something')."
      end
      unless I18n.backend or default
        raise ArgumentError, "You didn't supplied a default value. Because currently no backend is installed " +
          "(like the L10n gem) the localize method needs some fallback data to work with. Please specify a " +
          "default value (e.g. :name.localize 'Name') or install the L10n gem."
      end
    end
    
    # This method can be used by the object this module is mixed in to modify
    # the options (e.g. a string can specify itself as default value).
    def typify_localization_options(options)
      options
    end
    
    # Interpolates values into a given text.
    # 
    #   interpolate "file {{file}} opend by \\{{user}}", :file => 'test.txt', :user => 'Mr. X'  # => "file test.txt opend by {{user}}"
    # 
    # Note that you have to double escape the "\" when you want to escape
    # the {{...}} key in a string (once for the string and once for the
    # interpolation).
    # 
    # If a key is missing from the option hash and Locales.raise_exceptions
    # is set to true a MissingInterpolationKeyError exception will be raised.
    def interpolate(text, values = {})
      s = StringScanner.new text
      
      while s.skip_until /\{\{/
        s.string[s.pos - 3, 1] = '' and next if s.pre_match[-1, 1] == '\\'
        start_pos = s.pos - 2
        key_name = s.scan_until(/\}\}/)[0..-3]
        end_pos = s.pos - 1
        
        if values.has_key? key_name.to_sym
          s.string[start_pos..end_pos] = values[key_name.to_sym].to_s
        else
          raise MissingInterpolationKeyError, "The interpolation key #{key_name} is " +
            "missing in the argument list.\nText: #{text}\nSpecified interpolation " +
            "keys: #{values.inspect}" if I18n.raise_exceptions
        end        
        s.unscan
      end      
      s.string
    end
  end
end
