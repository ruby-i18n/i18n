$:.unshift 'lib/i18n/lib'

require 'rubygems'
require 'test/unit'
require 'mocha'
require 'active_support'
require 'action_pack'

require 'i18n'
require 'patch/number_helper'
require 'patch/translations'

class NumberHelperI18nTests < Test::Unit::TestCase
  include ActionView::Helpers::NumberHelper
  
  attr_reader :request
  def setup
    @request = mock
  end

  def test_number_to_currency_given_a_locale_it_does_not_check_request_for_locale
    request.expects(:locale).never
    number_to_currency(1, :locale => 'en-US')
  end

  def test_number_to_currency_given_no_locale_it_checks_request_for_locale
    request.expects(:locale).returns 'en-US'
    number_to_currency(1)
  end

  def test_number_to_currency_translates_currency_formats
    formats = {:separator => ".", :unit => "$", :format => "%u%n", :delimiter => ",", :precision => 2}
    I18n.expects(:translate).with(:'currency.format', 'en-US').returns formats
    number_to_currency(1, :locale => 'en-US')
  end
end