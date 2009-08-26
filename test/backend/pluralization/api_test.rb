# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'i18n/backend/pluralization'

module PluralizationSetup
  def setup
    super
    I18n.backend.meta_class.send(:include, I18n::Backend::Pluralization)
    I18n.load_path << locales_dir + '/plurals.rb'
  end

  def test_uses_pluralization
    assert I18n.backend.meta_class.included_modules.include?(I18n::Backend::Pluralization)
  end
end

class I18nPluralizationBackendApiBasicsTest < Test::Unit::TestCase
  include PluralizationSetup
  include Tests::Backend::Api::Basics
end

class I18nPluralizationBackendApiTranslateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include PluralizationSetup
  include Tests::Backend::Api::Translation
end

class I18nPluralizationBackendApiInterpolateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include PluralizationSetup
  include Tests::Backend::Api::Interpolation
end

class I18nPluralizationBackendApiLambdaTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include PluralizationSetup
  include Tests::Backend::Api::Lambda
end

class I18nPluralizationBackendApiTranslateLinkedTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include PluralizationSetup
  include Tests::Backend::Api::Link
end

class I18nPluralizationBackendApiPluralizeTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include PluralizationSetup
  include Tests::Backend::Api::Pluralization
end

class I18nPluralizationBackendApiLocalizeDateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include PluralizationSetup
  include Tests::Backend::Api::Localization::Date
end

class I18nPluralizationBackendApiLocalizeDateTimeTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include PluralizationSetup
  include Tests::Backend::Api::Localization::DateTime
end

class I18nPluralizationBackendApiLocalizeTimeTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include PluralizationSetup
  include Tests::Backend::Api::Localization::Time
end

class I18nPluralizationBackendApiLocalizeLambdaTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include PluralizationSetup
  include Tests::Backend::Api::Localization::Lambda
end

