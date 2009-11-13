# encoding: utf-8

module Tests
  module Backend
    module Api
      module Translation
        def translate(key, options = {})
          I18n.backend.translate('en', key, options)
        end

        def test_given_no_keys_it_returns_the_default
          assert_equal 'default', translate(nil, :default => 'default')
        end

        def test_translate_given_a_symbol_as_a_default_translates_the_symbol
          assert_equal 'bar', translate(nil, :default => :'foo.bar')
        end

        def test_translate_default_with_scope_stays_in_scope_when_looking_up_the_symbol
          assert_equal 'bar', translate(:missing, :default => :bar, :scope => :foo)
        end

        def test_translate_given_an_array_as_default_uses_the_first_match
          assert_equal 'bar', translate(:does_not_exist, :scope => [:foo], :default => [:does_not_exist_2, :bar])
        end

        def test_translate_given_an_array_of_inexistent_keys_it_raises_missing_translation_data
          assert_raises I18n::MissingTranslationData do
            translate(:does_not_exist, :scope => [:foo], :default => [:does_not_exist_2, :does_not_exist_3])
          end
        end

        def test_translate_an_array_of_keys_translates_all_of_them
          assert_equal %w(bar baz), translate([:bar, :baz], :scope => [:foo])
        end

        def test_translate_with_a_missing_key_and_no_default_raises_missing_translation_data
          assert_raises(I18n::MissingTranslationData) do
            translate(:missing)
          end
        end

        def test_translate_given_nil_as_a_locale_raises_an_argument_error
          assert_raises(I18n::InvalidLocale) do
            I18n.backend.translate(nil, :bar)
          end
        end
      end
    end
  end
end
