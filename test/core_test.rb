$:.unshift "lib/i18n/lib"

require 'test/unit'
require 'i18n'
require 'i18n/backend/simple'
I18n.backend = I18n::Backend::Simple
require 'i18n/backend/translations'
require 'patch/date_time'


class I18nDateTest < Test::Unit::TestCase
  def setup
    @date = Date.new 2008, 1, 1
  end
  
  def test_localize_given_the_short_format_it_uses_it
    assert_equal 'Jan 01', @date.localize('en-US', :short)
  end
  
  def test_localize_given_the_long_format_it_uses_it
    assert_equal 'January 01, 2008', @date.localize('en-US', :long)
  end
  
  def test_localize_given_the_default_format_it_uses_it
    assert_equal '2008-01-01', @date.localize('en-US', :default)
  end
  
  def test_localize_given_a_day_name_format_it_returns_a_day_name
    assert_equal 'Tuesday', @date.localize('en-US', '%A')
  end
  
  def test_localize_given_an_abbr_day_name_format_it_returns_an_abbrevated_day_name
    assert_equal 'Tue', @date.localize('en-US', '%a')
  end
  
  def test_localize_given_a_month_name_format_it_returns_a_month_name
    assert_equal 'January', @date.localize('en-US', '%B')
  end
  
  def test_localize_given_an_abbr_month_name_format_it_returns_an_abbrevated_month_name
    assert_equal 'Jan', @date.localize('en-US', '%b')
  end
  
  def test_localize_given_no_format_it_does_not_fail
    assert_nothing_raised{ @date.localize }
  end

  def test_localize_given_an_unknown_format_it_does_not_fail
    assert_nothing_raised{ @date.localize('en-US', '%x') }
  end  
end

class I18nTimeTest < Test::Unit::TestCase
  def setup
    @morning = Time.parse '2008-01-01 6:00 UTC'
    @evening = Time.parse '2008-01-01 18:00 UTC'
  end
  
  def test_localize_given_the_short_format_it_uses_it
    assert_equal '01 Jan 06:00', @morning.localize('en-US', :short)
  end
  
  def test_localize_given_the_long_format_it_uses_it
    assert_equal 'January 01, 2008 06:00', @morning.localize('en-US', :long)
  end
  
  def test_localize_given_the_default_format_it_uses_it
    assert_equal 'Tue, 01 Jan 2008 06:00:00 +0100', @morning.localize('en-US', :default)
  end
  
  def test_localize_given_a_day_name_format_it_returns_the_correct_day_name
    assert_equal 'Tuesday', @morning.localize('en-US', '%A')
  end
  
  def test_localize_given_an_abbr_day_name_format_it_returns_the_correct_abbrevated_day_name
    assert_equal 'Tue', @morning.localize('en-US', '%a')
  end
  
  def test_localize_given_a_month_name_format_it_returns_the_correct_month_name
    assert_equal 'January', @morning.localize('en-US', '%B')
  end
  
  def test_localize_given_an_abbr_month_name_format_it_returns_the_correct_abbrevated_month_name
    assert_equal 'Jan', @morning.localize('en-US', '%b')
  end
  
  def test_localize_given_a_meridian_indicator_format_it_returns_the_correct_meridian_indicator
    assert_equal 'am', @morning.localize('en-US', '%p')
    assert_equal 'pm', @evening.localize('en-US', '%p')
  end
  
  def test_localize_given_no_format_it_does_not_fail
    assert_nothing_raised{ @morning.localize }
  end
  
  def test_localize_given_an_unknown_format_it_does_not_fail
    assert_nothing_raised{ @morning.localize('en-US', '%x') }
  end  
end