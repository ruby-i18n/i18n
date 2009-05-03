# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class I18nSimpleBackendPluralizeTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def test_pluralize_given_nil_returns_the_given_entry
    entry = {:one => 'bar', :other => 'bars'}
    assert_equal entry, @backend.send(:pluralize, nil, entry, nil)
  end

  def test_pluralize_given_0_returns_zero_string_if_zero_key_given
    assert_equal 'zero', @backend.send(:pluralize, nil, {:zero => 'zero', :one => 'bar', :other => 'bars'}, 0)
  end

  def test_pluralize_given_0_returns_plural_string_if_no_zero_key_given
    assert_equal 'bars', @backend.send(:pluralize, nil, {:one => 'bar', :other => 'bars'}, 0)
  end

  def test_pluralize_given_1_returns_singular_string
    assert_equal 'bar', @backend.send(:pluralize, nil, {:one => 'bar', :other => 'bars'}, 1)
  end

  def test_pluralize_given_2_returns_plural_string
    assert_equal 'bars', @backend.send(:pluralize, nil, {:one => 'bar', :other => 'bars'}, 2)
  end

  def test_pluralize_given_3_returns_plural_string
    assert_equal 'bars', @backend.send(:pluralize, nil, {:one => 'bar', :other => 'bars'}, 3)
  end

  def test_interpolate_given_incomplete_pluralization_data_raises_invalid_pluralization_data
    assert_raises(I18n::InvalidPluralizationData){ @backend.send(:pluralize, nil, {:one => 'bar'}, 2) }
  end

  def test_pluralize_given_pluralization_data_as_default
    assert_equal 'bars', I18n.t(:bar, :count => 2, :default => { :one => 'bar', :other => 'bars' })
  end
end

