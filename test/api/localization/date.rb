# encoding: utf-8

module Tests
  module Backend
    module Api
      module Localization
        module Date
          # TODO should be Mrz, shouldn't it?
          def test_localize_given_the_short_format_it_uses_it
            assert_equal '01. Mar', I18n.backend.localize('de', date, :short)
          end

          def test_localize_given_the_long_format_it_uses_it
            assert_equal '01. März 2008', I18n.backend.localize('de', date, :long)
          end

          def test_localize_given_the_default_format_it_uses_it
            assert_equal '01.03.2008', I18n.backend.localize('de', date, :default)
          end

          def test_localize_given_a_day_name_format_it_returns_a_day_name
            assert_equal 'Samstag', I18n.backend.localize('de', date, '%A')
          end

          def test_localize_given_an_abbr_day_name_format_it_returns_an_abbrevated_day_name
            assert_equal 'Sa', I18n.backend.localize('de', date, '%a')
          end

          def test_localize_given_a_month_name_format_it_returns_a_month_name
            assert_equal 'März', I18n.backend.localize('de', date, '%B')
          end

          # TODO should be Mrz, shouldn't it?
          def test_localize_given_an_abbr_month_name_format_it_returns_an_abbrevated_month_name
            assert_equal 'Mar', I18n.backend.localize('de', date, '%b')
          end

          def test_localize_given_a_format_specified_as_a_proc
            assert_equal '1ter März 2008', I18n.backend.localize('de', date, :long_ordinalized)
          end

          def test_localize_given_a_format_specified_as_a_proc_with_additional_options
            assert_equal '1ter März 2008 (MEZ)', I18n.backend.localize('de', date, :long_ordinalized, :timezone => 'MEZ')
          end

          def test_localize_given_no_format_it_does_not_fail
            assert_nothing_raised{ I18n.backend.localize 'de', date }
          end

          def test_localize_given_an_unknown_format_it_does_not_fail
            assert_nothing_raised{ I18n.backend.localize 'de', date, '%x' }
          end

          def test_localize_nil_raises_argument_error
            assert_raises(I18n::ArgumentError) { I18n.backend.localize 'de', nil }
          end

          def test_localize_object_raises_argument_error
            assert_raises(I18n::ArgumentError) { I18n.backend.localize 'de', Object.new }
          end
        end
      end
    end
  end
end