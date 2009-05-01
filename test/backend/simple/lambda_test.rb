# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class I18nSimpleBackendLambdaTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def test_translate_simple_proc
    setup_proc_translation
    assert_equal 'bar=bar, baz=baz, foo=foo', @backend.translate('en', :a_lambda, :foo => 'foo', :bar => 'bar', :baz => 'baz')
  end

  def test_translate_proc_in_defaults
    setup_proc_translation
    assert_equal 'bar=bar, baz=baz, foo=foo', @backend.translate('en', :does_not_exist, :default => :a_lambda, :foo => 'foo', :bar => 'bar', :baz => 'baz')
    assert_equal 'bar=bar, baz=baz, foo=foo', @backend.translate('en', :does_not_exist, :default => [:does_not_exist_2, :does_not_exist_3, :a_lambda], :foo => 'foo', :bar => 'bar', :baz => 'baz')
  end

  def test_translate_proc_with_pluralize
    setup_proc_translation
    params = { :zero => 'zero', :one => 'one', :other => 'other' }
    assert_equal 'zero', @backend.translate('en', :lambda_for_pluralize, params.merge(:count => 0))
    assert_equal 'one', @backend.translate('en', :lambda_for_pluralize, params.merge(:count => 1))
    assert_equal 'other', @backend.translate('en', :lambda_for_pluralize, params.merge(:count => 2))
  end

  def test_translate_proc_with_interpolate
    setup_proc_translation
    assert_equal 'bar baz foo', @backend.translate('en', :lambda_for_interpolate, :foo => 'foo', :bar => 'bar', :baz => 'baz')
  end

  def test_translate_with_proc_as_default
    expected = 'result from lambda'
    assert_equal expected, @backend.translate(:en, :'does not exist', :default => lambda { expected })
  end

  private
    def setup_proc_translation
      @backend.store_translations 'en', {
        :a_lambda => lambda { |key, values|
          values.keys.sort_by(&:to_s).collect { |key| "#{key}=#{values[key]}"}.join(', ')
        },
        :lambda_for_pluralize => lambda { |key, values| values },
        :lambda_for_interpolate => lambda { |key, values|
          "{{#{values.keys.sort_by(&:to_s).join('}} {{')}}}"
        }
      }
    end
end

