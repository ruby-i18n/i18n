require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module I18nSimpleBackendTestSetup
  def setup_backend
    # backend_reset_translations!
    @backend = I18n::Backend::Simple.new
    @backend.store_translations :en, :foo => {:bar => 'bar', :baz => 'baz'}
    @locale_dir = File.dirname(__FILE__) + '/../../locale'
  end
  alias :setup :setup_backend

  # def backend_reset_translations!
  #   I18n::Backend::Simple::ClassMethods.send :class_variable_set, :@@translations, {}
  # end

  def backend_get_translations
    # I18n::Backend::Simple::ClassMethods.send :class_variable_get, :@@translations
    @backend.instance_variable_get :@translations
  end

  def add_datetime_translations
    @backend.store_translations :de, {
      :date => {
        :formats => {
          :default => "%d.%m.%Y",
          :short => "%d. %b",
          :long => "%d. %B %Y",
          :long_ordinalized => lambda { |date, options|
            tz = " (#{options[:timezone]})" if options[:timezone]
            "#{date.day}ter %B %Y#{tz}"
          }
        },
        :day_names => %w(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag),
        :abbr_day_names => %w(So Mo Di Mi Do Fr  Sa),
        :month_names => %w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember).unshift(nil),
        :abbr_month_names => %w(Jan Feb Mar Apr Mai Jun Jul Aug Sep Okt Nov Dez).unshift(nil),
        :order => [:day, :month, :year]
      },
      :time => {
        :formats => {
          :default => "%a, %d. %b %Y %H:%M:%S %z",
          :short => "%d. %b %H:%M",
          :long => "%d. %B %Y %H:%M",
          :long_ordinalized => lambda { |date, options|
            tz = " (#{options[:timezone]})" if options[:timezone]
            "#{date.day}ter %B %Y, %H:%M Uhr#{tz}"
          }
        },
        :am => 'am',
        :pm => 'pm'
      },
      :datetime => {
        :distance_in_words => {
          :half_a_minute => 'half a minute',
          :less_than_x_seconds => {
            :one => 'less than 1 second',
            :other => 'less than {{count}} seconds'
          },
          :x_seconds => {
            :one => '1 second',
            :other => '{{count}} seconds'
          },
          :less_than_x_minutes => {
            :one => 'less than a minute',
            :other => 'less than {{count}} minutes'
          },
          :x_minutes => {
            :one => '1 minute',
            :other => '{{count}} minutes'
          },
          :about_x_hours => {
            :one => 'about 1 hour',
            :other => 'about {{count}} hours'
          },
          :x_days => {
            :one => '1 day',
            :other => '{{count}} days'
          },
          :about_x_months => {
            :one => 'about 1 month',
            :other => 'about {{count}} months'
          },
          :x_months => {
            :one => '1 month',
            :other => '{{count}} months'
          },
          :about_x_years => {
            :one => 'about 1 year',
            :other => 'about {{count}} year'
          },
          :over_x_years => {
            :one => 'over 1 year',
            :other => 'over {{count}} years'
          }
        }
      }
    }
  end
end