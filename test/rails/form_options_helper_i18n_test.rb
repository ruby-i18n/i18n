$:.unshift 'lib/i18n/lib'

require 'rubygems'
require 'test/unit'
require 'mocha'
require 'active_support'
require 'action_pack'

require 'i18n'
require 'patch/form_options_helper'
require 'patch/translations'

class FormOptionsHelperI18nTests < Test::Unit::TestCase
  include ActionView::Helpers::FormOptionsHelper

  def test_country_options_for_select_translates_country_names
    countries = ActionView::Helpers::FormOptionsHelper::COUNTRIES
    I18n.expects(:translate).with(:'countries.names', 'en-US').returns countries
    country_options_for_select(:locale => 'en-US')
  end  
end