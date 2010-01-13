# encoding: utf-8
require 'cldr'

module I18n
  module Backend
    module Cldr
      include ::Cldr::Format

      def localize(locale, object, format = :default, options = {})
        case object
        when ::Numeric
          format(locale, object, { :as => :number }.merge(options.merge(:format => format)))
        when ::Date, ::DateTime, ::Time
          format = :medium if format == :default # TODO :default is missing in cldr extraction
          format(locale, object, { :as => object.class.name.downcase }.merge(options.merge(:format => format)))
        else
          super
        end
      end

      protected

        def lookup_format(locale, type, format)
          case type
          when :date, :datetime, :time
            I18n.t(:"calendars.gregorian.formats.#{type}.#{format}.pattern", :locale => locale, :raise => true)
          else
            I18n.t(:"numbers.formats.#{type}.patterns.#{format || :default}", :locale => locale, :raise => true)
          end
        end

        def lookup_format_data(locale, type)
          case type
          when :date, :datetime, :time
            I18n.t(:'calendars.gregorian', :locale => locale, :raise => true)
          else
            I18n.t(:'numbers.symbols', :locale => locale, :raise => true)
          end
        end

        def lookup_currency(locale, currency, count)
          I18n.t(:"currencies.#{currency}", :locale => locale, :count => count)
        end
    end
  end
end