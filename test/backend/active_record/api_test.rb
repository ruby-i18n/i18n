# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'i18n/backend/active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
ActiveRecord::Schema.define(:version => 1) do
  create_table :translations do |t|
    t.string :locale
    t.string :key
    t.string :value
    t.boolean :proc
  end
end

class I18nActiveRecordBackendApiBasicsTest < Test::Unit::TestCase
  include Tests::Backend::ActiveRecord::Setup::Base
  include Tests::Backend::Api::Basics
end

class I18nActiveRecordBackendApiTranslateTest < Test::Unit::TestCase
  include Tests::Backend::ActiveRecord::Setup::Base
  include Tests::Backend::Api::Translation
end

class I18nActiveRecordBackendApiInterpolateTest < Test::Unit::TestCase
  include Tests::Backend::ActiveRecord::Setup::Base
  include Tests::Backend::Api::Interpolation
end

class I18nActiveRecordBackendApiLambdaTest < Test::Unit::TestCase
  include Tests::Backend::ActiveRecord::Setup::Base
  include Tests::Backend::Api::Lambda
end

class I18nActiveRecordBackendApiTranslateLinkedTest < Test::Unit::TestCase
  include Tests::Backend::ActiveRecord::Setup::Base
  include Tests::Backend::Api::Link
end

class I18nActiveRecordBackendApiPluralizationTest < Test::Unit::TestCase
  include Tests::Backend::ActiveRecord::Setup::Base
  include Tests::Backend::Api::Pluralization
end

class I18nActiveRecordBackendApiLocalizeDateTest < Test::Unit::TestCase
  include Tests::Backend::ActiveRecord::Setup::Localization
  include Tests::Backend::Api::Localization::Date
end

class I18nActiveRecordBackendApiLocalizeDateTimeTest < Test::Unit::TestCase
  include Tests::Backend::ActiveRecord::Setup::Localization
  include Tests::Backend::Api::Localization::DateTime
end

class I18nActiveRecordBackendApiLocalizeTimeTest < Test::Unit::TestCase
  include Tests::Backend::ActiveRecord::Setup::Localization
  include Tests::Backend::Api::Localization::Time
end

class I18nActiveRecordBackendApiLocalizeLambdaTest < Test::Unit::TestCase
  include Tests::Backend::ActiveRecord::Setup::Localization
  include Tests::Backend::Api::Localization::Lambda
end

