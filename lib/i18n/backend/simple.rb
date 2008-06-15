require 'date'

module I18n
  module Backend
    module Simple
      @@translations = {}
      
      class << self
        def translations
          @@translations
        end
        
        def add_translations(locale, data)
          @@translations[locale] ||= {}
          # deep_merge by Stefan Rusterholz, seed http://www.ruby-forum.com/topic/142809
          @@translations[locale].merge! data, &proc {|key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        end
        
        def translate(options = {})
          options[:locale] ||= Locale.current
          entry = lookup options[:locale], *options[:keys]
          entry ||= options[:default] if options[:default]
          entry = pluralize entry, options[:count]
          entry = interpolate entry, options.reject{|key, value| [:keys, :locale, :default].include? key } 
          entry
        end
        
        def lookup(*keys)
          keys.inject(translations){|result, key| result[key.to_sym] or return nil }
        end
    
        def pluralize(entry, count)
          return entry unless entry.is_a?(Array) and count
          entry[plural_index(count)].dup
        end
      
        def plural_index(count)
          count.nil? || count == 1 ? 0 : 1
        end
    
        # Interpolates values into a given string.
        # 
        #   interpolate "file {{file}} opend by \\{{user}}", :file => 'test.txt', :user => 'Mr. X'  # => "file test.txt opend by {{user}}"
        # 
        # Note that you have to double escape the "\" when you want to escape
        # the {{...}} key in a string (once for the string and once for the
        # interpolation).
        def interpolate(string, values = {})
          return string if values.empty?
          
          s = StringScanner.new string.dup
          while s.skip_until /\{\{/
            s.string[s.pos - 3, 1] = '' and next if s.pre_match[-1, 1] == '\\'
            start_pos = s.pos - 2
            key_name = s.scan_until(/\}\}/)[0..-3]
            end_pos = s.pos - 1
        
            if values.has_key? key_name.to_sym
              s.string[start_pos..end_pos] = values[key_name.to_sym].to_s
            end        
            s.unscan
          end      
          s.string
        end
      end
    end
  end
end
