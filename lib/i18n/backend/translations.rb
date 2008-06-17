I18n.backend.add_translations :'en-US', {
  :date => {
    :formats => {
      :default => "%Y-%m-%d",
      :short => "%b %d",
      :long => "%B %d, %Y",
    },
    :day_names => Date::DAYNAMES,
    :abbr_day_names => Date::ABBR_DAYNAMES,
    :month_names => Date::MONTHNAMES,
    :abbr_month_names => Date::ABBR_MONTHNAMES,
    :order => [:year, :month, :day]
  },
  :time => {
    :formats => {
      :default => "%a, %d %b %Y %H:%M:%S %z",
      :short => "%d %b %H:%M",
      :long => "%B %d, %Y %H:%M",
    },
    :am => 'am',
    :pm => 'pm'
  },
  :datetime => {
    :distance_in_words => {
      :half_a_minute       => 'half a minute',
      :less_than_x_seconds => ['less than 1 second', 'less than {{count}} seconds'],
      :x_seconds           => ['1 second', '{{count}} seconds'],
      :less_than_x_minutes => ['less than a minute', 'less than {{count}} minutes'],
      :x_minutes           => ['1 minute', '{{count}} minutes'],
      :about_x_hours       => ['about 1 hour', 'about {{count}} hours'],
      :x_days              => ['1 day', '{{count}} days'],
      :about_x_months      => ['about 1 month', 'about {{count}} months'],
      :x_months            => ['1 month', '{{count}} months'],
      :about_x_years       => ['about 1 year', 'about {{count}} year'],
      :over_x_years        => ['over 1 year', 'over {{count}} years']
    }
  },
  :currency => {
    :format => {
      :unit => '$',
      :precision => 2,
      :separator => '.',
      :delimiter => ',',
      :format => '%u%n',
    }
  },
  :support => {
    :array => {
      :sentence_connector => 'and'
    }
  },
  :active_record => {
    :error => {
      :header_message => ["{{count}} error prohibited this {{object_name}} from being saved", "{{count}} errors prohibited this {{object_name}} from being saved"],
      :message => "There were problems with the following fields:"
    },
    :error_messages => {
      :inclusion => "is not included in the list",
      :exclusion => "is reserved",
      :invalid => "is invalid",
      :confirmation => "doesn't match confirmation",
      :accepted  => "must be accepted",
      :empty => "can't be empty",
      :blank => "can't be blank",
      :too_long => "is too long (maximum is {{count}} characters)",
      :too_short => "is too short (minimum is {{count}} characters)",
      :wrong_length => "is the wrong length (should be {{count}} characters)",
      :taken => "has already been taken",
      :not_a_number => "is not a number",
      :greater_than => "must be greater than {{count}}",
      :greater_than_or_equal_to => "must be greater than or equal to {{count}}",
      :equal_to => "must be equal to {{count}}",
      :less_than => "must be less than {{count}}",
      :less_than_or_equal_to => "must be less than or equal to {{count}}",
      :odd => "must be odd",
      :even => "must be even"
    }            
  }
}


# TODO define these here? pass them as default value?
# if Object.const_defined?('ActionView')
#   I18n.backend.add_translations :'en-US', :countries => {
#     :names => ::ActionView::Helpers::FormOptionsHelper.const_get('COUNTRIES')
#   }
# end

# if Object.const_defined?('ActiveRecord')
#   I18n.backend.add_translations :'en-US', :active_record => {
#     :error_messages => ActiveRecord::Errors.default_error_messages
#   }
# end



