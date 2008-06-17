module I18n
  module Backend
    module Simple
      class ReservedInterpolationKey < ArgumentError; end
      @@translations = {}
      
      class << self
        def translations
          @@translations
        end
        
        def add_translations(locale, data)
          locale = locale.to_sym
          @@translations[locale] ||= {}
          # deep_merge by Stefan Rusterholz, seed http://www.ruby-forum.com/topic/142809
          merger = proc {|key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
          @@translations[locale].merge! data, &merger
        end
        
        def translate(options = {})
          reserved = :locale, :keys, :default
          count, locale, keys, default = options.values_at(:count, *reserved)
          values = options.reject{|key, value| reserved.include? key } 
          
          entry = lookup(locale || I18n.current_locale, *keys) || default
          entry = pluralize entry, count
          entry = interpolate entry, values
          entry
        end
        
        def lookup(*keys)
          return if keys.size <= 1
          keys.inject(translations){|result, key| result[key.to_sym] or return nil }
        end
    
        def pluralize(entry, count)
          return entry unless entry.is_a?(Array) and count
          plural_index = count.nil? || count == 1 ? 0 : 1
          entry[plural_index].dup
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
          return string if string.nil? or values.nil? or values.empty?

          map = {'%d' => '{{count}}', '%s' => '{{value}}'} # TODO deprecate this
          string.gsub!(/#{map.keys.join('|')}/){|key| map[key]} 
          
          s = StringScanner.new string.dup
          reserved = :locale, :keys, :default
          while s.skip_until /\{\{/
            s.string[s.pos - 3, 1] = '' and next if s.pre_match[-1, 1] == '\\'
            
            start_pos = s.pos - 2
            key = s.scan_until(/\}\}/)[0..-3]
            end_pos = s.pos - 1            

            raise ReservedInterpolationKey, %s(reserved key :#{key} used in "#{string}") if reserved.include?(key)
        
            s.string[start_pos..end_pos] = values[key.to_sym].to_s if values.has_key? key.to_sym
            s.unscan
          end      
          s.string
        end
        
        def localize(object, locale = nil, format = :default)
          type = object.respond_to?(:sec) ? 'time' : 'date'

          formats = :"#{type}.formats".t locale
          format = formats[format.to_sym] if formats[format.to_sym]      
          format = format.dup
    
          format.gsub! /%a/, :abbr_day_names.t(locale, :scope => :date)[object.wday]
          format.gsub! /%A/, :day_names.t(locale, :scope => :date)[object.wday]
          format.gsub! /%b/, :abbr_month_names.t(locale, :scope => :date)[object.mon]
          format.gsub! /%B/, :month_names.t(locale, :scope => :date)[object.mon]
          format.gsub! /%p/, (object.hour < 12 ? :am : :pm).t(locale, :scope => :time) if object.respond_to? :hour
          object.strftime(format)
        end
      end
    end
  end
end
