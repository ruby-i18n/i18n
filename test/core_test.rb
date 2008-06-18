$:.unshift "lib/i18n/lib"

require 'rubygems'
require 'test/unit'
require 'mocha'
require 'i18n'

class I18nStringTest < Test::Unit::TestCase
  def setup
    @string = 'foo'
  end
  
  def test_translate_unshifts_self_to_arguments
    I18n.expects(:translate).with @string, 'en-US'
    @string.translate 'en-US'
  end
end

class I18nSymbolTest < Test::Unit::TestCase
  def setup
    @symbol = :foo
  end
  
  def test_translate_unshifts_self_to_arguments
    I18n.expects(:translate).with @symbol, 'en-US'
    @symbol.translate 'en-US'
  end
end

class I18nDateTest < Test::Unit::TestCase
  def setup
    @date = Date.new 2008, 1, 1
  end
  
  def test_translate_unshifts_self_to_arguments
    I18n.expects(:localize).with @date, 'en-US'
    @date.localize 'en-US'
  end
end

class I18nDateTimeTest < Test::Unit::TestCase
  def setup
    @datetime = DateTime.new 2008, 1, 1, 6
  end
  
  def test_translate_unshifts_self_to_arguments
    I18n.expects(:localize).with @datetime, 'en-US'
    @datetime.localize 'en-US'
  end
end

class I18nTimeTest < Test::Unit::TestCase
  def setup
    @time = Time.parse '2008-01-01 6:00 UTC'
  end
  
  def test_translate_unshifts_self_to_arguments
    I18n.expects(:localize).with @time, 'en-US'
    @time.localize 'en-US'
  end
end