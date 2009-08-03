module Tests
  module Backend
    module ActiveRecord
      module Setup
        module Base
          def setup
            super
            I18n.locale = nil
            I18n.default_locale = :en
            I18n.backend = I18n::Backend::ActiveRecord.new
            backend_store_translations :en, :foo => {:bar => 'bar', :baz => 'baz'}
          end

          def teardown
            super
            Translation.destroy_all
            I18n.backend = nil
          end
        end

        module Localization
          include Base

          def setup
            super
            setup_datetime_translations
            setup_datetime_lambda_translations
            @old_timezone, ENV['TZ'] = ENV['TZ'], 'UTC'
          end

          def teardown
            super
            @old_timezone ? ENV['TZ'] = @old_timezone : ENV.delete('TZ')
          end

          def setup_datetime_translations
            backend_store_translations :de, {
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

          def setup_datetime_lambda_translations
            backend_store_translations 'ru', {
              :date => {
                :'day_names' => lambda { |key, options|
                  (options[:format] =~ /^%A/) ?
                  %w(Воскресенье Понедельник Вторник Среда Четверг Пятница Суббота) :
                  %w(воскресенье понедельник вторник среда четверг пятница суббота)
                },
                :'abbr_day_names' => %w(Вс Пн Вт Ср Чт Пт Сб),
                :'month_names' => lambda { |key, options|
                  (options[:format] =~ /(%d|%e)(\s*)?(%B)/) ?
                  %w(января февраля марта апреля мая июня июля августа сентября октября ноября декабря).unshift(nil) :
                  %w(Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь).unshift(nil)
                },
                :'abbr_month_names' => lambda { |key, options|
                  (options[:format] =~ /(%d|%e)(\s*)(%b)/) ?
                  %w(янв. февр. марта апр. мая июня июля авг. сент. окт. нояб. дек.).unshift(nil) :
                  %w(янв. февр. март апр. май июнь июль авг. сент. окт. нояб. дек.).unshift(nil)
                },
              },
              :time => {
                :am => "утра",
                :pm => "вечера"
              }
            }
          end
        end
      end
    end
  end
end