require 'strscan'

module I18n
  module Backend
    class ReservedInterpolationKey < ArgumentError; end
    module Simple
      @@translations = {}
      
      class << self
        # Returns all translations that are currently stored in memory.
        def translations
          @@translations
        end
        
        # Allow client libraries to pass a block that populates the translation
        # storage. Decoupled for backends like a db backend that persist their
        # translations, so the backend can decide whether/when to yield or not.
        def populate(&block)
          yield
        end
        
        # Stores translations for the given locale in memory. 
        # This uses a deep merge for the translations hash, so existing
        # translations will be overwritten by new ones only at the deepest
        # level of the hash.
        def store_translations(locale, data)
          merge_translations(locale, data)
        end
        
        def translate(key, locale, options = {})
          raise ArgumentError, 'locale is nil in I18n::Backend::Simple#translate' if locale.nil?
          return key.map{|key| translate key, locale, options } if key.is_a? Array

          reserved = :scope, :default
          count, scope, default = options.values_at(:count, *reserved)
          options.delete(:default)
          values = options.reject{|name, value| reserved.include? name } 

          entry = lookup(locale, key, scope) || default(locale, default, options)
          entry = pluralize entry, count
          entry = interpolate entry, values
          entry
        end
        
        # Looks up a translation from the translations hash. Returns nil if 
        # key is nil or locale, scope or key do not exist as a key in the
        # nested translations hash. Splits keys or scopes containing dots
        # into multiple keys, i.e. "currency.format" is regarded the same as
        # %w(currency format).
        def lookup(locale, key, scope = [])
          return unless key
          keys = normalize_keys locale, key, scope
          keys.inject(translations){|result, key| result[key.to_sym] or return nil }
        end
        
        # Evaluates a default translation.
        # 
        # If the given default is a String it is used literally. If it is a Symbol
        # it will be translated with the given options. If it is an Array the first
        # translation yielded will be returned.
        # 
        # I.e. default(locale, [:foo, 'default']) will return 'default' if 
        # translate(locale, :foo) does not yield a result.
        def default(locale, default, options = {})
          case default
            when String then default
            when Symbol then default.translate(locale, options)
            when Array  then default.each do |obj| 
              result = default(locale, obj, options.dup) and return result
            end
          end
        end
        
        # Picks a translation from an array according to English pluralization
        # rules. It will pick the first translation if count is not equal to 1
        # and the second translation if it is equal to 1. Other backends can
        # implement more flexible or complex pluralization rules.
        def pluralize(entry, count)
          return entry unless entry.is_a?(Array) && count
          entry[count == 1 ? 0 : 1].dup
        end
    
        # Interpolates values into a given string.
        # 
        #   interpolate "file {{file}} opend by \\{{user}}", :file => 'test.txt', :user => 'Mr. X'  
        #   # => "file test.txt opend by {{user}}"
        # 
        # Note that you have to double escape the "\" when you want to escape
        # the {{...}} key in a string (once for the string and once for the
        # interpolation).
        def interpolate(string, values = {})
          return string if string.nil? or values.empty?

          map = {'%d' => '{{count}}', '%s' => '{{value}}'} # TODO deprecate this?
          string.gsub!(/#{map.keys.join('|')}/){|key| map[key]} 
          
          s = StringScanner.new string.dup
          while s.skip_until(/\{\{/)
            s.string[s.pos - 3, 1] = '' and next if s.pre_match[-1, 1] == '\\'            
            start_pos = s.pos - 2
            key = s.scan_until(/\}\}/)[0..-3]
            end_pos = s.pos - 1            

            raise ReservedInterpolationKey, %s(reserved key :#{key} used in "#{string}") if %w(scope default).include?(key)
        
            s.string[start_pos..end_pos] = values[key.to_sym].to_s if values.has_key? key.to_sym
            s.unscan
          end      
          s.string
        end
        
        # Acts the same as #strftime, but returns a localized version of the 
        # formatted date string. Takes a key from the date/time formats 
        # translations as a format argument (e.g. :short in :'date.formats')        
        def localize(object, locale = nil, format = :default)
          type = object.respond_to?(:sec) ? 'time' : 'date'
          formats = :"#{type}.formats".t locale
          format = formats[format.to_sym] if formats && formats[format.to_sym]
          # TODO raise exception unless format found?
          format = format.to_s.dup

          format.gsub!(/%a/, :"date.abbr_day_names".t(locale)[object.wday])
          format.gsub!(/%A/, :"date.day_names".t(locale)[object.wday])
          format.gsub!(/%b/, :"date.abbr_month_names".t(locale)[object.mon])
          format.gsub!(/%B/, :"date.month_names".t(locale)[object.mon])
          format.gsub!(/%p/, :"time.#{object.hour < 12 ? :am : :pm}".t(locale)) if object.respond_to? :hour
          object.strftime(format)
        end
        
        protected
          
          # Deep merges the given translations hash with the existing translations
          # for the given locale
          def merge_translations(locale, data)
            locale = locale.to_sym
            data = deep_symbolize_keys data
            @@translations[locale] ||= {}
            # deep_merge by Stefan Rusterholz, seed http://www.ruby-forum.com/topic/142809
            merger = proc{|key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
            @@translations[locale].merge! data, &merger
          end
          
          # Merges the given locale, key and scope into a single array of keys.
          # Splits keys that contain dots into multiple keys. Makes sure all
          # keys are Symbols.
          def normalize_keys(locale, key, scope)
            keys = [locale] + Array(scope) + [key]
            keys = keys.map{|key| key.to_s.split(/\./) }
            keys.flatten.map{|key| key.to_sym}
          end
          
          # Return a new hash with all keys and nested keys converted to symbols.
          def deep_symbolize_keys(hash)
            hash.inject({}){|result, (key, value)|
              value = deep_symbolize_keys(value) if value.is_a? Hash
              result[(key.to_sym rescue key) || key] = value
              result
            }
          end          
      end
    end
  end
end
