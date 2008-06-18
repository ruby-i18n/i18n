$:.unshift "lib/i18n/lib"

require 'rubygems'
require 'test/unit'
require 'mocha'

require 'i18n'

module I18nSimpleBackendTestSetup
  def setup_backend
    @backend = I18n::Backend::Simple
    @backend.translations.clear
    @backend.add_translations 'en-US', :foo => {:bar => 'bar'}
  end
  alias :setup :setup_backend
  
  def add_datetime_translations
    @backend.add_translations :'de-DE', {
      :date => {
        :formats => {
          :default => "%d.%m.%Y",
          :short => "%d. %b",
          :long => "%d. %B %Y",
        },
        :day_names => %w(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag),
        :abbr_day_names => %w(So Mo Di Mi Do Fr  Sa),
        :month_names => %w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember).unshift(nil),
        :abbr_month_names => %w(Jan Feb Mar Apr Mai Jun Jul Aug Sep Okt Nov Dez).unshift(nil),
        :order => [:day, :month, :year]
      },
      :time => {
        :formats => {
          :default => "%a, %d. %b %Y %H:%M:%S %z",
          :short => "%d. %b %H:%M",
          :long => "%d. %B %Y %H:%M",
        },
        :am => 'am',
        :pm => 'pm'
      },
      :datetime => {
        :distance_in_words => {
          :half_a_minute       => 'half a minute',
          :less_than_x_seconds => ['less than 1 second', 'less than {{count}} seconds'],
          :x_seconds           => ['1 second', '{{count}} seconds'],
          :less_than_x_minutes => ['less than a minute', 'less than {{count}} minutes'],
          :x_minutes           => ['1 minute', '{{count}} minutes'],
          :about_x_hours       => ['about 1 hour', 'about {{count}} hours'],
          :x_days              => ['1 day', '{{count}} days'],
          :about_x_months      => ['about 1 month', 'about {{count}} months'],
          :x_months            => ['1 month', '{{count}} months'],
          :about_x_years       => ['about 1 year', 'about {{count}} year'],
          :over_x_years        => ['over 1 year', 'over {{count}} years']
        }
      }  
    }
  end
end

class I18nSimpleBackendTranslationsTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup
  
  def test_add_translations_adds_translations # no, really :-)
    @backend.add_translations :'en-US', :foo => 'bar'
    assert_equal Hash[:'en-US', {:foo => 'bar'}], @backend.translations
  end
  
  def test_add_translations_deep_merges_translations
    @backend.add_translations :'en-US', :foo => {:bar => 'bar'}
    @backend.add_translations :'en-US', :foo => {:baz => 'baz'}
    assert_equal Hash[:'en-US', {:foo => {:bar => 'bar', :baz => 'baz'}}], @backend.translations
  end
  
  def test_add_translations_forces_locale_to_sym
    @backend.add_translations 'en-US', :foo => 'bar'
    assert_equal Hash[:'en-US', {:foo => 'bar'}], @backend.translations
  end
end
  
class I18nSimpleBackendTranslateTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def test_translate_calls_lookup_with_locale_given
    @backend.expects(:lookup).with 'de-DE', :foo, :bar
    @backend.translate :locale => 'de-DE', :keys => [:foo, :bar]
  end
  
  def test_translate_given_no_locale_calls_lookup_with_i18n_current_locale
    @backend.expects(:lookup).with 'en-US', :foo, :bar
    @backend.translate :keys => [:foo, :bar]
  end
  
  def test_translate_given_nil_as_locale_calls_lookup_with_i18n_current_locale
    @backend.expects(:lookup).with 'en-US', :foo, :bar
    @backend.translate :locale => nil, :keys => [:foo, :bar]
  end
  
  def test_translate_calls_pluralize
    @backend.expects(:pluralize).with 'bar', 1
    @backend.translate :keys => [:foo, :bar], :count => 1
  end
  
  def test_translate_calls_interpolate
    @backend.expects(:interpolate).with 'bar', {}
    @backend.translate :keys => [:foo, :bar]
  end
  
  def test_translate_calls_interpolate_including_count_as_a_value
    @backend.expects(:interpolate).with 'bar', {:count => 1}
    @backend.translate :keys => [:foo, :bar], :count => 1
  end
end
  
class I18nSimpleBackendLookupTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup

  def test_lookup_given_no_keys_returns_nil
    assert_nil @backend.lookup
  end
  
  # useful because this way we can use the backend with no key for interpolation/pluralization
  def test_lookup_given_only_a_locale_returns_nil 
    assert_nil @backend.lookup('en-US')
  end
  
  def test_lookup_given_nested_keys_looks_up_a_nested_hash_value
    assert_equal 'bar', @backend.lookup('en-US', :foo, :bar)    
  end
end
  
class I18nSimpleBackendPluralizeTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup
  
  def test_pluralize_given_nil_returns_the_given_entry
    assert_equal ['bar', 'bars'], @backend.pluralize(['bar', 'bars'], nil)
  end
  
  def test_pluralize_given_0_returns_plural_string
    assert_equal 'bars', @backend.pluralize(['bar', 'bars'], 0)
  end
  
  def test_pluralize_given_1_returns_singular_string
    assert_equal 'bar', @backend.pluralize(['bar', 'bars'], 1)
  end
  
  def test_pluralize_given_2_returns_plural_string
    assert_equal 'bars', @backend.pluralize(['bar', 'bars'], 2)
  end
end
  
class I18nSimpleBackendInterpolateTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup
  
  def test_interpolate_given_a_value_hash_interpolates_the_values_to_the_string
    assert_equal 'Hi David!', @backend.interpolate('Hi {{name}}!', :name => 'David')
  end
  
  def test_interpolate_given_nil_as_a_string_returns_nil
    assert_nil @backend.interpolate(nil, :name => 'David')
  end
  
  def test_interpolate_given_an_empty_values_hash_returns_the_unmodified_string
    assert_equal 'Hi {{name}}!', @backend.interpolate('Hi {{name}}!', {})
  end
  
  def test_interpolate_given_a_values_hash_with_nil_values_interpolates_the_string
    assert_equal 'Hi !', @backend.interpolate('Hi {{name}}!', {:name => nil})
  end
  
  def test_interpolate_given_a_string_containing_a_reserved_key_raises_an_exception
    assert_raises(I18n::Backend::ReservedInterpolationKey) { @backend.interpolate('{{default}}', {:default => nil}) }
  end
end

class I18nSimpleBackendLocalizeDateTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup
  
  def setup
    @backend = I18n::Backend::Simple
    add_datetime_translations
    @date = Date.new 2008, 1, 1
  end
  
  def test_translate_given_the_short_format_it_uses_it
    assert_equal '01. Jan', @backend.localize(@date, 'de-DE', :short)
  end
  
  def test_translate_given_the_long_format_it_uses_it
    assert_equal '01. Januar 2008', @backend.localize(@date, 'de-DE', :long)
  end
  
  def test_translate_given_the_default_format_it_uses_it
    assert_equal '01.01.2008', @backend.localize(@date, 'de-DE', :default)
  end
  
  def test_translate_given_a_day_name_format_it_returns_a_day_name
    assert_equal 'Dienstag', @backend.localize(@date, 'de-DE', '%A')
  end
  
  def test_translate_given_an_abbr_day_name_format_it_returns_an_abbrevated_day_name
    assert_equal 'Di', @backend.localize(@date, 'de-DE', '%a')
  end
  
  def test_translate_given_a_month_name_format_it_returns_a_month_name
    assert_equal 'Januar', @backend.localize(@date, 'de-DE', '%B')
  end
  
  def test_translate_given_an_abbr_month_name_format_it_returns_an_abbrevated_month_name
    assert_equal 'Jan', @backend.localize(@date, 'de-DE', '%b')
  end
  
  def test_translate_given_no_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize @date, 'de-DE' }
  end
  
  def test_translate_given_an_unknown_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize @date, 'de-DE', '%x' }
  end  
end

class I18nSimpleBackendLocalizeDateTimeTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup
  
  def setup
    @backend = I18n::Backend::Simple
    add_datetime_translations
    @morning = DateTime.new 2008, 1, 1, 6
    @evening = DateTime.new 2008, 1, 1, 18
  end
  
  def test_translate_given_the_short_format_it_uses_it
    assert_equal '01. Jan 06:00', @backend.localize(@morning, 'de-DE', :short)
  end
  
  def test_translate_given_the_long_format_it_uses_it
    assert_equal '01. Januar 2008 06:00', @backend.localize(@morning, 'de-DE', :long)
  end
  
  def test_translate_given_the_default_format_it_uses_it
    assert_equal 'Di, 01. Jan 2008 06:00:00 +0000', @backend.localize(@morning, 'de-DE', :default)
  end
  
  def test_translate_given_a_day_name_format_it_returns_the_correct_day_name
    assert_equal 'Dienstag', @backend.localize(@morning, 'de-DE', '%A')
  end
  
  def test_translate_given_an_abbr_day_name_format_it_returns_the_correct_abbrevated_day_name
    assert_equal 'Di', @backend.localize(@morning, 'de-DE', '%a')
  end
  
  def test_translate_given_a_month_name_format_it_returns_the_correct_month_name
    assert_equal 'Januar', @backend.localize(@morning, 'de-DE', '%B')
  end
  
  def test_translate_given_an_abbr_month_name_format_it_returns_the_correct_abbrevated_month_name
    assert_equal 'Jan', @backend.localize(@morning, 'de-DE', '%b')
  end
  
  def test_translate_given_a_meridian_indicator_format_it_returns_the_correct_meridian_indicator
    assert_equal 'am', @backend.localize(@morning, 'de-DE', '%p')
    assert_equal 'pm', @backend.localize(@evening, 'de-DE', '%p')
  end
  
  def test_translate_given_no_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize @morning, 'de-DE' }
  end
  
  def test_translate_given_an_unknown_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize @morning, 'de-DE', '%x' }
  end 
end

class I18nSimpleBackendLocalizeTimeTest < Test::Unit::TestCase
  include I18nSimpleBackendTestSetup
  
  def setup
    @backend = I18n::Backend::Simple
    add_datetime_translations
    @morning = Time.parse '2008-01-01 6:00 UTC'
    @evening = Time.parse '2008-01-01 18:00 UTC'
  end
  
  def test_translate_given_the_short_format_it_uses_it
    assert_equal '01. Jan 06:00', @backend.localize(@morning, 'de-DE', :short)
  end
  
  def test_translate_given_the_long_format_it_uses_it
    assert_equal '01. Januar 2008 06:00', @backend.localize(@morning, 'de-DE', :long)
  end
  
  def test_translate_given_the_default_format_it_uses_it
    assert_equal 'Di, 01. Jan 2008 06:00:00 +0100', @backend.localize(@morning, 'de-DE', :default)
  end
  
  def test_translate_given_a_day_name_format_it_returns_the_correct_day_name
    assert_equal 'Dienstag', @backend.localize(@morning, 'de-DE', '%A')
  end
  
  def test_translate_given_an_abbr_day_name_format_it_returns_the_correct_abbrevated_day_name
    assert_equal 'Di', @backend.localize(@morning, 'de-DE', '%a')
  end
  
  def test_translate_given_a_month_name_format_it_returns_the_correct_month_name
    assert_equal 'Januar', @backend.localize(@morning, 'de-DE', '%B')
  end
  
  def test_translate_given_an_abbr_month_name_format_it_returns_the_correct_abbrevated_month_name
    assert_equal 'Jan', @backend.localize(@morning, 'de-DE', '%b')
  end
  
  def test_translate_given_a_meridian_indicator_format_it_returns_the_correct_meridian_indicator
    assert_equal 'am', @backend.localize(@morning, 'de-DE', '%p')
    assert_equal 'pm', @backend.localize(@evening, 'de-DE', '%p')
  end
  
  def test_translate_given_no_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize @morning, 'de-DE' }
  end
  
  def test_translate_given_an_unknown_format_it_does_not_fail
    assert_nothing_raised{ @backend.localize @morning, 'de-DE', '%x' }
  end  
end