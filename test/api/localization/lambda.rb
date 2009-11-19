# encoding: utf-8

module Tests
  module Backend
    module Api
      module Localization
        module Lambda
          def test_localize_uses_lambda_day_names
            assert_match /Суббота/, I18n.backend.localize('ru', time, "%A, %d %B")
            assert_match /суббота/, I18n.backend.localize('ru', time, "%d %B (%A)")
          end

          def test_localize_uses_lambda_month_names
            assert_match /марта/, I18n.backend.localize('ru', time, "%d %B %Y")
            assert_match /Март/, I18n.backend.localize('ru', time, "%B %Y")
          end

          def test_localize_uses_lambda_abbr_day_names
            assert_match /марта/, I18n.backend.localize('ru', time, "%d %b %Y")
            assert_match /март/, I18n.backend.localize('ru', time, "%b %Y")
          end
        end
      end
    end
  end
end
