# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'i18n/backend/fallbacks'

module FallbacksSetup
  class Backend
    include I18n::Backend::Base
    include I18n::Backend::Fallbacks
  end

  def setup
    I18n.backend = Backend.new
    super
  end

  def test_uses_fallbacks
    assert I18n.backend.class.included_modules.include?(I18n::Backend::Fallbacks)
  end
end

class I18nFallbacksBackendApiBasicsTest < Test::Unit::TestCase
  include FallbacksSetup
  include Tests::Backend::Api::Basics
end

class I18nFallbacksBackendApiTranslateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include FallbacksSetup
  include Tests::Backend::Api::Translation
end

class I18nFallbacksBackendApiInterpolateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include FallbacksSetup
  include Tests::Backend::Api::Interpolation
end

class I18nFallbacksBackendApiLambdaTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include FallbacksSetup
  include Tests::Backend::Api::Lambda
end

class I18nFallbacksBackendApiTranslateLinkedTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include FallbacksSetup
  include Tests::Backend::Api::Link
end

class I18nFallbacksBackendApiPluralizationTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include FallbacksSetup
  include Tests::Backend::Api::Pluralization
end

class I18nFallbacksBackendApiLocalizeDateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include FallbacksSetup
  include Tests::Backend::Api::Localization::Date
end

class I18nFallbacksBackendApiLocalizeDateTimeTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include FallbacksSetup
  include Tests::Backend::Api::Localization::DateTime
end

class I18nFallbacksBackendApiLocalizeTimeTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include FallbacksSetup
  include Tests::Backend::Api::Localization::Time
end

class I18nFallbacksBackendApiLocalizeLambdaTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include FallbacksSetup
  include Tests::Backend::Api::Localization::Lambda
end

