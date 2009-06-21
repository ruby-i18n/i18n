# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class I18nSimpleBackendInterpolateTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def test_interpolate_given_a_value_hash_interpolates_the_values_to_the_string
    assert_equal 'Hi David!', @backend.send(:interpolate, nil, 'Hi {{name}}!', :name => 'David')
  end

  def test_interpolate_with_ruby_1_9_syntax
    assert_equal 'Hi David!', @backend.send(:interpolate, nil, 'Hi %{name}!', :name => 'David')
  end

  def test_interpolate_given_a_value_hash_interpolates_into_unicode_string
    assert_equal 'Häi David!', @backend.send(:interpolate, nil, 'Häi {{name}}!', :name => 'David')
  end

  def test_interpolate_given_an_unicode_value_hash_interpolates_to_the_string
    assert_equal 'Hi ゆきひろ!', @backend.send(:interpolate, nil, 'Hi {{name}}!', :name => 'ゆきひろ')
  end

  def test_interpolate_given_an_unicode_value_hash_interpolates_into_unicode_string
    assert_equal 'こんにちは、ゆきひろさん!', @backend.send(:interpolate, nil, 'こんにちは、{{name}}さん!', :name => 'ゆきひろ')
  end

  if Kernel.const_defined?(:Encoding)
    def test_interpolate_given_a_non_unicode_multibyte_value_hash_interpolates_into_a_string_with_the_same_encoding
      assert_equal euc_jp('Hi ゆきひろ!'), @backend.send(:interpolate, nil, 'Hi {{name}}!', :name => euc_jp('ゆきひろ'))
    end

    def test_interpolate_given_an_unicode_value_hash_into_a_non_unicode_multibyte_string_raises_encoding_compatibility_error
      assert_raises(Encoding::CompatibilityError) do
        @backend.send(:interpolate, nil, euc_jp('こんにちは、{{name}}さん!'), :name => 'ゆきひろ')
      end
    end

    def test_interpolate_given_a_non_unicode_multibyte_value_hash_into_an_unicode_string_raises_encoding_compatibility_error
      assert_raises(Encoding::CompatibilityError) do
        @backend.send(:interpolate, nil, 'こんにちは、{{name}}さん!', :name => euc_jp('ゆきひろ'))
      end
    end
  end

  def test_interpolate_given_nil_as_a_string_returns_nil
    assert_nil @backend.send(:interpolate, nil, nil, :name => 'David')
  end

  def test_interpolate_given_an_non_string_as_a_string_returns_nil
    assert_equal [], @backend.send(:interpolate, nil, [], :name => 'David')
  end

  def test_interpolate_given_a_values_hash_with_nil_values_interpolates_the_string
    assert_equal 'Hi !', @backend.send(:interpolate, nil, 'Hi {{name}}!', {:name => nil})
  end

  def test_interpolate_given_an_empty_values_hash
    assert_equal 'Hi {{name}}!', @backend.send(:interpolate, nil, 'Hi {{name}}!', {})
  end

  def test_interpolate_given_a_string_containing_a_reserved_key_raises_reserved_interpolation_key
    assert_raises(I18n::ReservedInterpolationKey) { @backend.send(:interpolate, nil, '{{default}}', {:default => nil}) }
  end

  private

  def euc_jp(string)
    string.encode!(Encoding::EUC_JP)
  end
end

