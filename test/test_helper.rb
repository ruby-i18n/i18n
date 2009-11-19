# encoding: utf-8

$:.unshift "lib"

require 'rubygems'
require 'test/unit'
require 'mocha'
require 'i18n'
require 'i18n/core_ext/object/meta_class'
require 'time'
require 'yaml'

require File.dirname(__FILE__) + '/with_options'
require File.dirname(__FILE__) + '/backend/simple/setup'
require File.dirname(__FILE__) + '/backend/active_record/setup'

Dir[File.dirname(__FILE__) + '/api/**/*.rb'].each do |filename|
  require filename
end

$KCODE = 'u' unless RUBY_VERSION >= '1.9'

class Test::Unit::TestCase
  def self.test(name, &block)
    define_method("test: " + name, &block)
  end

  def euc_jp(string)
    string.encode!(Encoding::EUC_JP)
  end

  def locales_dir
    File.dirname(__FILE__) + '/fixtures/locales'
  end

  def backend_store_translations(*args)
    I18n.backend.store_translations(*args)
  end

  def backend_get_translations
    I18n.backend.instance_variable_get :@translations
  end

  def date
    Date.new(2008, 3, 1)
  end

  def morning_datetime
    DateTime.new(2008, 3, 1, 6)
  end
  alias :datetime :morning_datetime

  def evening_datetime
    DateTime.new(2008, 3, 1, 18)
  end

  def morning_time
    Time.parse('2008-03-01 6:00 UTC')
  end
  alias :time :morning_time

  def evening_time
    Time.parse('2008-03-01 18:00 UTC')
  end
end
