module ActionView  
  module Helpers   
    module FormOptionsHelper
      def country_options_for_select(*args)
        options = args.extract_options!
        selected, priority_countries = *args
        
        countries = :'countries.names'.t options[:locale], :default => COUNTRIES
        country_options = ""

        if priority_countries
          # TODO priority_countries need to be translated, right?
          country_options += options_for_select(priority_countries, selected)
          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end

        return country_options + options_for_select(countries, selected)
      end
    end
  end
end