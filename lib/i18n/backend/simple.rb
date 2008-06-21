require 'strscan'

module I18n
  module Backend
    class ReservedInterpolationKey < ArgumentError; end
    module Simple
      @@translations = {}
      
      class << self
        def translations
          @@translations
        end
        
        # Allow client libraries to pass a block that populates the translation
        # storage. Decoupled for backends like a db backend that persist their
        # translations.
        def populate(&block)
          yield
        end
        
        def store_translations(locale, data)
          merge_translations(locale, data)
        end
        
        def translate(key, locale, options = {})
          return key.map{|key| translate key, locale, options } if key.is_a? Array

          reserved = :scope, :default
          count, scope, default = options.values_at(:count, *reserved)
          options.delete(:default)

          values = options.reject{|name, value| reserved.include? name } 
          keys = (scope || []).dup << key

          entry = lookup(locale, *keys.compact) if key
          entry ||= default(locale, default, options)
          entry = pluralize entry, count
          entry = interpolate entry, values
          entry
        end
        
        def lookup(*keys)
          return if keys.size <= 1
          keys.inject(translations){|result, key| result[key.to_sym] or return nil }
        end
        
        def default(locale, default, options)
          case default
            when String then default
            when Symbol then default.translate(locale, options)
            when Array  then
              result = nil
              default.detect{|default| result = default(locale, default, options.dup) }
              result
          end
        end
    
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

          map = {'%d' => '{{count}}', '%s' => '{{value}}'} # TODO deprecate this
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
          
          def merge_translations(locale, data)
            locale = locale.to_sym
            @@translations[locale] ||= {}
            # deep_merge by Stefan Rusterholz, seed http://www.ruby-forum.com/topic/142809
            merger = proc {|key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
            @@translations[locale].merge! data, &merger
          end
      end
    end
  end
end
