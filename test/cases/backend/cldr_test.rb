# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'i18n/backend/cldr'

class I18nBackendCldrTest < Test::Unit::TestCase
  class Backend
    include I18n::Backend::Base
    include I18n::Backend::Cldr
  end

  def setup
    I18n.backend = Backend.new
    I18n.locale = :de
    I18n.load_path += Dir[locales_dir + '/cldr/**/*.{yml,rb}']
    super
  end

  define_method :"test: format_number" do
    assert_equal '123.456,78', I18n.l(123456.78)
  end

  define_method :"test: format_currency" do
    assert_equal '123.456,78 EUR', I18n.l(123456.78, :currency => 'EUR')
  end

  # hu? does this actually make any sense?
  define_method :"test: format_currency translating currency names" do 
    assert_equal '1,00 Irisches Pfund', I18n.l(1, :currency => :IEP)
    assert_equal '2,00 Irische Pfund',  I18n.l(2, :currency => :IEP)
  end

  # this is odd but the cldr percent format does not include a fraction
  define_method :"test: format_percent" do
    assert_equal '123.457 %', I18n.l(123456.78, :as => :percent)
  end

  # so we can pass a precision manually
  define_method :"test: format_percent w/ precision" do
    assert_equal '123.456,70 %', I18n.l(123456.7, :as => :percent, :precision => 2)
  end
end
