require 'action_view/helpers/form_options_helper'

module ActionView  
  module Helpers   
    module FormOptionsHelper
      def country_options_for_select(*args)
        options = args.extract_options!
        options[:locale] ||= request.locale if respond_to?(:request)
        
        selected, priority_countries = *args        
        countries = :'countries.names'.t options[:locale] # TODO, :default => COUNTRIES
        country_options = ""

        if priority_countries
          # TODO priority_countries need to be translated?
          country_options += options_for_select(priority_countries, selected)
          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end

        return country_options + options_for_select(countries, selected)
      end
    end
  end
end