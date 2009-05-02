# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class I18nSimpleBackendLocalizeDateTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def setup
    @backend = I18n::Backend::Simple.new
    add_datetime_translations
    @date = Date.new 2008, 1, 1
  end

  def test_localize_given_the_short_format_it_uses_it
    assert_equal '01. Jan', @backend.localize('de', @date, :short)
  end

  def test_localize_given_the_long_format_it_uses_it
    assert_equal '01. Januar 2008', @backend.localize('de', @date, :long)
  end

  def test_localize_given_the_default_format_it_uses_it
    assert_equal '01.01.2008', @backend.localize('de', @date, :default)
  end

  def test_localize_given_a_day_name_format_it_returns_a_day_name
    assert_equal 'Dienstag', @backend.localize('de', @date, '%A')
  end

  def test_localize_given_an_abbr_day_name_format_it_returns_an_abbrevated_day_name
    assert_equal 'Di', @backend.localize('de', @date, '%a')
  end

  def test_localize_given_a_month_name_format_it_returns_a_month_name
    assert_equal 'Januar', @backend.localize('de', @date, '%B')
  end

  def test_localize_given_an_abbr_month_name_format_it_returns_an_abbrevated_month_name
    assert_equal 'Jan', @backend.localize('de', @date, '%b')
  end

  def test_localize_given_a_format_specified_as_a_proc
    assert_equal '1ter Januar 2008', @backend.localize('de', @date, :long_ordinalized)
  end

  def test_localize_given_a_format_specified_as_a_proc_with_additional_options
    assert_equal '1ter Januar 2008 (MEZ)', @backend.localize('de', @date, :long_ordinalized, :timezone => 'MEZ')
  end

  def test_localize_given_no_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize 'de', @date }
  end

  def test_localize_given_an_unknown_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize 'de', @date, '%x' }
  end

  def test_localize_nil_raises_argument_error
    assert_raises(I18n::ArgumentError) { @backend.localize 'de', nil }
  end

  def test_localize_object_raises_argument_error
    assert_raises(I18n::ArgumentError) { @backend.localize 'de', Object.new }
  end
end

class I18nSimpleBackendLocalizeDateTimeTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def setup
    @backend = I18n::Backend::Simple.new
    add_datetime_translations
    @morning = DateTime.new 2008, 1, 1, 6
    @evening = DateTime.new 2008, 1, 1, 18
  end

  def test_localize_given_the_short_format_it_uses_it
    assert_equal '01. Jan 06:00', @backend.localize('de', @morning, :short)
  end

  def test_localize_given_the_long_format_it_uses_it
    assert_equal '01. Januar 2008 06:00', @backend.localize('de', @morning, :long)
  end

  def test_localize_given_the_default_format_it_uses_it
    assert_equal 'Di, 01. Jan 2008 06:00:00 +0000', @backend.localize('de', @morning, :default)
  end

  def test_localize_given_a_day_name_format_it_returns_the_correct_day_name
    assert_equal 'Dienstag', @backend.localize('de', @morning, '%A')
  end

  def test_localize_given_an_abbr_day_name_format_it_returns_the_correct_abbrevated_day_name
    assert_equal 'Di', @backend.localize('de', @morning, '%a')
  end

  def test_localize_given_a_month_name_format_it_returns_the_correct_month_name
    assert_equal 'Januar', @backend.localize('de', @morning, '%B')
  end

  def test_localize_given_an_abbr_month_name_format_it_returns_the_correct_abbrevated_month_name
    assert_equal 'Jan', @backend.localize('de', @morning, '%b')
  end

  def test_localize_given_a_meridian_indicator_format_it_returns_the_correct_meridian_indicator
    assert_equal 'am', @backend.localize('de', @morning, '%p')
    assert_equal 'pm', @backend.localize('de', @evening, '%p')
  end

  def test_localize_given_a_format_specified_as_a_proc
    assert_equal '1ter Januar 2008, 06:00 Uhr', @backend.localize('de', @morning, :long_ordinalized)
  end

  def test_localize_given_a_format_specified_as_a_proc_with_additional_options
    assert_equal '1ter Januar 2008, 06:00 Uhr (MEZ)', @backend.localize('de', @morning, :long_ordinalized, :timezone => 'MEZ')
  end

  def test_localize_given_no_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize 'de', @morning }
  end

  def test_localize_given_an_unknown_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize 'de', @morning, '%x' }
  end
end

class I18nSimpleBackendLocalizeTimeTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def setup
    @old_timezone, ENV['TZ'] = ENV['TZ'], 'UTC'
    @backend = I18n::Backend::Simple.new
    add_datetime_translations
    @morning = Time.parse '2008-01-01 6:00 UTC'
    @evening = Time.parse '2008-01-01 18:00 UTC'
  end

  def teardown
    @old_timezone ? ENV['TZ'] = @old_timezone : ENV.delete('TZ')
  end

  def test_localize_given_the_short_format_it_uses_it
    assert_equal '01. Jan 06:00', @backend.localize('de', @morning, :short)
  end

  def test_localize_given_the_long_format_it_uses_it
    assert_equal '01. Januar 2008 06:00', @backend.localize('de', @morning, :long)
  end

  # TODO Seems to break on Windows because ENV['TZ'] is ignored. What's a better way to do this?
  # def test_localize_given_the_default_format_it_uses_it
  #   assert_equal 'Di, 01. Jan 2008 06:00:00 +0000', @backend.localize('de', @morning, :default)
  # end

  def test_localize_given_a_day_name_format_it_returns_the_correct_day_name
    assert_equal 'Dienstag', @backend.localize('de', @morning, '%A')
  end

  def test_localize_given_an_abbr_day_name_format_it_returns_the_correct_abbrevated_day_name
    assert_equal 'Di', @backend.localize('de', @morning, '%a')
  end

  def test_localize_given_a_month_name_format_it_returns_the_correct_month_name
    assert_equal 'Januar', @backend.localize('de', @morning, '%B')
  end

  def test_localize_given_an_abbr_month_name_format_it_returns_the_correct_abbrevated_month_name
    assert_equal 'Jan', @backend.localize('de', @morning, '%b')
  end

  def test_localize_given_a_meridian_indicator_format_it_returns_the_correct_meridian_indicator
    assert_equal 'am', @backend.localize('de', @morning, '%p')
    assert_equal 'pm', @backend.localize('de', @evening, '%p')
  end

  def test_localize_given_a_format_specified_as_a_proc
    assert_equal '1ter Januar 2008, 06:00 Uhr', @backend.localize('de', @morning, :long_ordinalized)
  end

  def test_localize_given_a_format_specified_as_a_proc_with_additional_options
    assert_equal '1ter Januar 2008, 06:00 Uhr (MEZ)', @backend.localize('de', @morning, :long_ordinalized, :timezone => 'MEZ')
  end

  def test_localize_given_no_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize 'de', @morning }
  end

  def test_localize_given_an_unknown_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize 'de', @morning, '%x' }
  end
end

class I18nSimpleBackendLocalizeLambdaTest < Test::Unit::TestCase
  $KCODE = 'u'
  
  include I18nSimpleBackendTestSetup

  def setup
    @backend = I18n::Backend::Simple.new
    @time = Time.parse '2008-03-01 6:00 UTC'

    @backend.store_translations 'ru', {
      :date => {
        :'day_names' => lambda { |key, options| 
          (options[:format] =~ /^%A/) ? 
          %w(Воскресенье Понедельник Вторник Среда Четверг Пятница Суббота) : 
          %w(воскресенье понедельник вторник среда четверг пятница суббота)
        },
        :'abbr_day_names' => %w(Вс Пн Вт Ср Чт Пт Сб),
        :'month_names' => lambda { |key, options| 
          (options[:format] =~ /(%d|%e)(\s*)?(%B)/) ? 
          %w(января февраля марта апреля мая июня июля августа сентября октября ноября декабря).unshift(nil) :
          %w(Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь).unshift(nil) 
        },
        :'abbr_month_names' => lambda { |key, options| 
          (options[:format] =~ /(%d|%e)(\s*)(%b)/) ? 
          %w(янв. февр. марта апр. мая июня июля авг. сент. окт. нояб. дек.).unshift(nil) :
          %w(янв. февр. март апр. май июнь июль авг. сент. окт. нояб. дек.).unshift(nil)
        },
      },
      :time => {
        :am => "утра",
        :pm => "вечера"
      }
    }
  end

  def test_localize_uses_lambda_day_names
    assert_match /Суббота/, @backend.localize('ru', @time, "%A, %d %B")
    assert_match /суббота/, @backend.localize('ru', @time, "%d %B (%A)")
  end

  def test_localize_uses_lambda_month_names
    assert_match /марта/, @backend.localize('ru', @time, "%d %B %Y")
    assert_match /Март/, @backend.localize('ru', @time, "%B %Y")
  end
  
  def test_localize_uses_lambda_abbr_day_names
    assert_match /марта/, @backend.localize('ru', @time, "%d %b %Y")
    assert_match /март/, @backend.localize('ru', @time, "%b %Y")
  end
end
