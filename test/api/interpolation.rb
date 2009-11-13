# encoding: utf-8

module Tests
  module Backend
    module Api
      module Interpolation
        def interpolate(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          key = args.pop
          I18n.backend.translate('en', key, options)
        end

        def test_interpolation_given_no_interpolation_values_it_does_not_alter_the_string
          assert_equal 'Hi {{name}}!', interpolate(:default => 'Hi {{name}}!')
        end

        def test_interpolation_given_interpolation_values_it_interpolates_the_values_to_the_string
          assert_equal 'Hi David!', interpolate(:default => 'Hi {{name}}!', :name => 'David')
        end

        def test_interpolation_given_interpolation_values_with_nil_values_it_interpolates_the_values_to_the_string
          assert_equal 'Hi !', interpolate(:default => 'Hi {{name}}!', :name => nil)
        end

        def test_interpolation_given_a_lambda_as_a_value_it_calls_it_when_the_string_contains_the_key
          assert_equal 'Hi David!', interpolate(:default => 'Hi {{name}}!', :name => lambda { 'David' })
        end

        def test_interpolation_given_a_lambda_as_a_value_it_does_not_call_it_when_the_string_does_not_contain_the_key
          assert_nothing_raised { interpolate(:default => 'Hi!', :name => lambda { raise 'fail' }) }
        end

        def test_interpolation_given_interpolation_values_but_missing_a_key_it_raises_a_missing_interpolation_argument_exception
          assert_raises(I18n::MissingInterpolationArgument) do
            interpolate(:default => '{{foo}}', :bar => 'bar')
          end
        end

        def test_interpolation_does_not_raise_missing_interpolation_argument_exceptions_for_escaped_variables
          assert_nothing_raised(I18n::MissingInterpolationArgument) do
            assert_equal 'Barr {{foo}}', interpolate(:default => '{{bar}} \{{foo}}', :bar => 'Barr')
          end
        end

        def test_interpolation_does_not_change_the_original_stored_translation_string_and_allows_reinterpolation
          I18n.backend.store_translations(:en, :interpolate => 'Hi {{name}}!')
          assert_equal 'Hi David!', interpolate(:interpolate, :name => 'David')
          assert_equal 'Hi Yehuda!', interpolate(:interpolate, :name => 'Yehuda')
          # assert_equal 'Hi {{name}}!', I18n.backend.instance_variable_get(:@translations)[:en][:interpolate]
        end

        def test_interpolate_with_ruby_1_9_syntax
          assert_equal 'Hi David!', interpolate(:default => 'Hi %{name}!', :name => 'David')
        end

        def test_interpolate_given_a_value_hash_interpolates_into_unicode_string
          assert_equal 'Häi David!', interpolate(:default => 'Häi {{name}}!', :name => 'David')
        end

        def test_interpolate_given_a_unicode_value_hash_interpolates_to_the_string
          assert_equal 'Hi ゆきひろ!', interpolate(:default => 'Hi {{name}}!', :name => 'ゆきひろ')
        end

        def test_interpolate_given_a_unicode_value_hash_interpolates_into_unicode_string
          assert_equal 'こんにちは、ゆきひろさん!', interpolate(:default => 'こんにちは、{{name}}さん!', :name => 'ゆきひろ')
        end

        if Kernel.const_defined?(:Encoding)
          def test_interpolate_given_a_non_unicode_multibyte_value_hash_interpolates_into_a_string_with_the_same_encoding
            assert_equal euc_jp('Hi ゆきひろ!'), interpolate(:default => 'Hi {{name}}!', :name => euc_jp('ゆきひろ'))
          end

          def test_interpolate_given_a_unicode_value_hash_into_a_non_unicode_multibyte_string_raises_encoding_compatibility_error
            assert_raises(Encoding::CompatibilityError) do
              interpolate(:default => euc_jp('こんにちは、{{name}}さん!'), :name => 'ゆきひろ')
            end
          end

          def test_interpolate_given_a_non_unicode_multibyte_value_hash_into_an_unicode_string_raises_encoding_compatibility_error
            assert_raises(Encoding::CompatibilityError) do
              interpolate(:default => 'こんにちは、{{name}}さん!', :name => euc_jp('ゆきひろ'))
            end
          end
        end

        def test_interpolate_given_a_string_containing_a_reserved_key_raises_reserved_interpolation_key
          assert_raises(I18n::ReservedInterpolationKey) { interpolate(:default => '{{default}}',   :foo => :bar) }
          assert_raises(I18n::ReservedInterpolationKey) { interpolate(:default => '{{scope}}',     :foo => :bar) }
          assert_raises(I18n::ReservedInterpolationKey) { interpolate(:default => '{{separator}}', :foo => :bar) }
        end
      end
    end
  end
end
