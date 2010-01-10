# encoding: utf-8
$:.unshift '/Volumes/Users/sven/Development/projects/i18n/cldr/lib'
require 'cldr'

module I18n
  module Backend
    module Cldr
      include ::Cldr::Format

      def localize(locale, object, format = :default, options = {})
        case object
        when ::Numeric
          format(locale, object, { :as => :number }.merge(options))
        else
          super
        end
      end
      
      protected

        def lookup_number_format(locale, type, format)
          I18n.t(:"numbers.formats.#{type}.#{format || :default}.pattern", :locale => locale)
        end

        def lookup_number_symbols(locale)
          I18n.t(:'numbers.symbols', :locale => locale)
        end
        
        def lookup_currency(locale, currency, count)
          I18n.t(:"currencies.#{currency}", :locale => locale, :count => count)
        end
    end
  end
end