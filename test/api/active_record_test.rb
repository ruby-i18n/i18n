# encoding: utf-8
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../')); $:.uniq!
require 'test_helper'

Test.setup_active_record

class I18nActiveRecordApiTest < Test::Unit::TestCase
  def setup
    I18n.backend = I18n::Backend::ActiveRecord.new
    super
  end

  include I18n::Tests::Basics
  include I18n::Tests::Defaults
  include I18n::Tests::Interpolation
  include I18n::Tests::Link
  include I18n::Tests::Lookup
  include I18n::Tests::Pluralization
  include I18n::Tests::Procs # unless RUBY_VERSION >= '1.9.1'

  include I18n::Tests::Localization::Date
  include I18n::Tests::Localization::DateTime
  include I18n::Tests::Localization::Time
  include I18n::Tests::Localization::Procs # unless RUBY_VERSION >= '1.9.1'

  test "make sure we use an ActiveRecord backend" do
    assert_equal I18n::Backend::ActiveRecord, I18n.backend.class
  end
end if defined?(ActiveRecord)
