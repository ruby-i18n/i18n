# encoding: utf-8

module I18n
  module Tests
    module Pluralization
      test "pluralization: given 0 it returns the :zero translation if it is defined" do
        assert_equal 'zero', I18n.t(:default => { :zero => 'zero' }, :count => 0)
      end

      test "pluralization: given 0 it returns the :other translation if :zero is not defined" do
        assert_equal 'bars', I18n.t(:default => { :other => 'bars' }, :count => 0)
      end

      test "pluralization: given 1 it returns the singular translation" do
        assert_equal 'bar', I18n.t(:default => { :one => 'bar' }, :count => 1)
      end

      test "pluralization: given 2 it returns the :other translation" do
        assert_equal 'bars', I18n.t(:default => { :other => 'bars' }, :count => 2)
      end

      test "pluralization: given 3 it returns the :other translation" do
        assert_equal 'bars', I18n.t(:default => { :other => 'bars' }, :count => 3)
      end

      test "pluralization: given nil it returns the whole entry" do
        assert_equal({ :one => 'bar' }, I18n.t(:default => { :one => 'bar' }, :count => nil))
      end

      test "pluralization: the result is not the stored translation object" do
        I18n.backend.store_translations(:en, :__plural => { :one => +'apple', :other => +'apples' })
        result = I18n.t(:__plural, :count => 1)
        result << '!'
        assert_equal 'apple', I18n.t(:__plural, :count => 1)
      end

      test "pluralization: the result is not frozen" do
        I18n.backend.store_translations(:en, :__frozen_plural => { :one => 'apple'.freeze, :other => 'apples'.freeze })
        assert_equal false, I18n.t(:__frozen_plural, :count => 1).frozen?
      end

      test "pluralization: given incomplete pluralization data it raises I18n::InvalidPluralizationData" do
        assert_raises(I18n::InvalidPluralizationData) { I18n.t(:default => { :one => 'bar' }, :count => 2) }
      end
    end
  end
end
