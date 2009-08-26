# encoding: utf-8

module Tests
  module Backend
    module Api
      module Pluralization
        def test_pluralize_given_0_returns_zero_string_if_zero_key_given
          assert_equal 'zero', I18n.t(:default => { :zero => 'zero' }, :count => 0)
        end

        def test_pluralize_given_0_returns_plural_string_if_no_zero_key_given
          assert_equal 'bars', I18n.t(:default => { :other => 'bars' }, :count => 0)
        end

        def test_pluralize_given_1_returns_singular_string
          assert_equal 'bar', I18n.t(:default => { :one => 'bar' }, :count => 1)
        end

        def test_pluralize_given_2_returns_plural_string
          assert_equal 'bars', I18n.t(:default => { :other => 'bars' }, :count => 2)
        end

        def test_pluralize_given_3_returns_plural_string
          assert_equal 'bars', I18n.t(:default => { :other => 'bars' }, :count => 3)
        end

        def test_pluralize_given_nil_returns_the_given_entry
          assert_equal({ :zero => 'zero' }, I18n.t(:default => { :zero => 'zero' }, :count => nil))
        end

        def test_interpolate_given_incomplete_pluralization_data_raises_invalid_pluralization_data
          assert_raises(I18n::InvalidPluralizationData){ I18n.t(:default => { :one => 'bar' }, :count => 2) }
        end
      end
    end
  end
end