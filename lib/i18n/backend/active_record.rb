require 'i18n/backend/base'
require 'i18n/backend/active_record/translation'
require 'i18n/hash'

module I18n
  module Backend
    class ActiveRecord < Base
      
      def reload!
      end

      def store_translations(locale, data)
        data.unwind.each{|key,v|
          Translation.create(:locale => locale.to_s, :key => key, :value => v)
        }        
      end
      
      def available_locales
        Translation.find(:all, :select => 'DISTINCT locale').map{|t| t.locale}
      end
      
      protected
        
        def lookup(locale, key, scope = [], separator = I18n.default_separator)
          return unless key
          separator ||=  "."
          flat_key = (Array(scope) + Array(key)).join( separator )
          
          result = Translation.locale(locale).key(flat_key).find(:first)
          return result.value if result
          results = Translation.locale(locale).keys(flat_key, separator)
          if results.empty?
            return nil
          else
            chop_range = (flat_key.size + separator.size)..-1
            return results.inject({}){|hash,r|
              hash[r.key.slice( chop_range )] = hash[r.value]
              hash
            }.wind
          end
        end
      
    end
  end
end