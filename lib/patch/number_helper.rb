require 'action_view/helpers/number_helper'
module ActionView  
  module Helpers    
    module NumberHelper
      def number_to_currency(number, options = {})
        options = options.symbolize_keys
        
        locale = options[:locale]
        locale ||= request.locale if respond_to?(:request)

        defaults  = :'currency.format'.t locale
        precision = options[:precision] || defaults[:precision]
        unit      = options[:unit]      || defaults[:unit]
        separator = options[:separator] || defaults[:separator]
        delimiter = options[:delimiter] || defaults[:delimiter]
        format    = options[:format]    || defaults[:format]
        separator = '' if precision == 0
        
        begin
          parts = number_with_precision(number, precision).split('.')
          format.gsub(/%n/, number_with_delimiter(parts[0], delimiter) + separator + parts[1].to_s).gsub(/%u/, unit)
        rescue
          number
        end
      end
    end
  end
end