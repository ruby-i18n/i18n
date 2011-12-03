require 'test_helper'

class I18nBackendLocalizationTest < Test::Unit::TestCase
  def setup
    I18n.backend = I18n::Backend::Simple.new
  end

  test "localize date with default format" do
    store_translations(:en, :date => {:formats => {:default => '%Y-%m-%d'}})
    assert_equal '2011-12-03', I18n.l(Date.parse('2011-12-03'))
  end

  test "localize datetime with default format" do
    store_translations(:en, :time => {:formats => {:default => '%d %m %Y %H:%M:%S %z'}})
    assert_equal '03 12 2011 18:32:41 +0000', I18n.l(DateTime.parse('2011-12-03T18:32:41'))
  end

  #test "localize time with default format" do
  #  store_translations(:en, :time => {:formats => {:default => '%d %m %Y %H:%M:%S %z'}})
  #  assert_equal '03 12 2011 18:32:41 +0000', I18n.l(Time.parse('2011-12-03T18:32:41+00:00').utc)
  #end

  test "localize date with custom format" do
    assert_equal '2011-12-03', I18n.l(Date.parse('2011-12-03'), :format => '%Y-%m-%d')
  end

  test "localize datetime with custom format" do
    assert_equal '03 12 2011 18:32:41 +0000', I18n.l(DateTime.parse('2011-12-03T18:32:41'), :format => '%d %m %Y %H:%M:%S %z')
  end

  test "localize datetime with abbreviated day name" do
    store_translations(:en, :date => {:abbr_day_names => %w(Sun Mon Tue Wed Thu Fri Sat)})
    assert_equal 'Mon', I18n.l(DateTime.parse('2011-12-05T18:32:41'), :format => '%a')
  end

  test "localize datetime with day name" do
    store_translations(:en, :date => {:day_names => %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)})
    assert_equal 'Monday', I18n.l(DateTime.parse('2011-12-05T18:32:41'), :format => '%A')
  end

  test "localize datetime with abbr month name" do
    store_translations(:en, :date => {:abbr_month_names => %w(~ Jan Feb Mar)})
    assert_equal 'Jan', I18n.l(DateTime.parse('2011-01-05T18:32:41'), :format => '%b')
  end

  test "localize datetime with month name" do
    store_translations(:en, :date => {:month_names => %w(~ January February March)})
    assert_equal 'January', I18n.l(DateTime.parse('2011-01-05T18:32:41'), :format => '%B')
  end

  test "localize datetime with am" do
    store_translations(:en, :time => {:am => 'a.m.', :pm => 'p.m.'})
    assert_equal 'p.m.', I18n.l(DateTime.parse('2011-01-05T18:32:41'), :format => '%p')
    assert_equal 'a.m.', I18n.l(DateTime.parse('2011-01-05T08:32:41'), :format => '%p')
  end

  test "localize date with custom complex default" do
    store_translations(:en, :date => {:formats => {:default => '%a, %A %b %B %Y-%m-%d'},
                                      :abbr_day_names => %w(Sun Mon Tue Wed Thu Fri Sat),
                                      :day_names => %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday),
                                      :abbr_month_names => %w(~ Jan Feb Mar),
                                      :month_names => %w(~ January February March)})

    assert_equal 'Wed, Wednesday Jan January 2011-01-05', I18n.l(Date.parse('2011-01-05'))
  end

  test "localize datetime with custom complex default" do
    store_translations(:en, :date => {:abbr_day_names => %w(Sun Mon Tue Wed Thu Fri Sat),
                                      :day_names => %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday),
                                      :abbr_month_names => %w(~ Jan Feb Mar),
                                      :month_names => %w(~ January February March)})

    store_translations(:en, :time => {:formats => {:default => '%a, %A %b %B %Y-%m-%d %H:%M:%S %z %p %P'},
                                      :am => 'a.m.',
                                      :pm => 'p.m.'})

    assert_equal 'Wed, Wednesday Jan January 2011-01-05 18:32:41 +0000 p.m. pm',
                 I18n.l(DateTime.parse('2011-01-05T18:32:41'))
  end

  test "localize datetime with complex custom format" do
    store_translations(:en, :date => {:abbr_day_names => %w(Sun Mon Tue Wed Thu Fri Sat),
                                      :day_names => %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday),
                                      :abbr_month_names => %w(~ Jan Feb Mar),
                                      :month_names => %w(~ January February March)})

    store_translations(:en, :time => {:am => 'a.m.',
                                      :pm => 'p.m.'})

    assert_equal 'Wed, Wednesday Jan January 2011-01-05 18:32:41 +0000 p.m. pm',
                 I18n.l(DateTime.parse('2011-01-05T18:32:41'),
                        :format => '%a, %A %b %B %Y-%m-%d %H:%M:%S %z %p %P')
  end
end
