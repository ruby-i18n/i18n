# encoding: utf-8

module Tests
  module Backend
    module Api
      module Localization
        module DateTime
          # TODO should be Mrz, shouldn't it?
          def test_localize_given_the_short_format_it_uses_it
            assert_equal '01. Mar 06:00', I18n.backend.localize('de', morning_datetime, :short)
          end

          def test_localize_given_the_long_format_it_uses_it
            assert_equal '01. März 2008 06:00', I18n.backend.localize('de', morning_datetime, :long)
          end

          # TODO should be Mrz, shouldn't it?
          def test_localize_given_the_default_format_it_uses_it
            assert_equal 'Sa, 01. Mar 2008 06:00:00 +0000', I18n.backend.localize('de', morning_datetime, :default)
          end

          def test_localize_given_a_day_name_format_it_returns_the_correct_day_name
            assert_equal 'Samstag', I18n.backend.localize('de', morning_datetime, '%A')
          end

          def test_localize_given_an_abbr_day_name_format_it_returns_the_correct_abbrevated_day_name
            assert_equal 'Sa', I18n.backend.localize('de', morning_datetime, '%a')
          end

          def test_localize_given_a_month_name_format_it_returns_the_correct_month_name
            assert_equal 'März', I18n.backend.localize('de', morning_datetime, '%B')
          end

          # TODO should be Mrz, shouldn't it?
          def test_localize_given_an_abbr_month_name_format_it_returns_the_correct_abbrevated_month_name
            assert_equal 'Mar', I18n.backend.localize('de', morning_datetime, '%b')
          end

          def test_localize_given_a_meridian_indicator_format_it_returns_the_correct_meridian_indicator
            assert_equal 'am', I18n.backend.localize('de', morning_datetime, '%p')
            assert_equal 'pm', I18n.backend.localize('de', evening_datetime, '%p')
          end

          def test_localize_given_a_format_specified_as_a_proc
            assert_equal '1ter März 2008, 06:00 Uhr', I18n.backend.localize('de', morning_datetime, :long_ordinalized)
          end

          def test_localize_given_a_format_specified_as_a_proc_with_additional_options
            assert_equal '1ter März 2008, 06:00 Uhr (MEZ)', I18n.backend.localize('de', morning_datetime, :long_ordinalized, :timezone => 'MEZ')
          end

          def test_localize_given_no_format_it_does_not_fail
            assert_nothing_raised{ I18n.backend.localize 'de', morning_datetime }
          end

          def test_localize_given_an_unknown_format_it_does_not_fail
            assert_nothing_raised{ I18n.backend.localize 'de', morning_datetime, '%x' }
          end
        end
      end
    end
  end
end