# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'i18n/backend/chain'

module AllSetup
  class Backend
    include I18n::Backend::Base
    include I18n::Backend::Cache
    include I18n::Backend::Metadata
    include I18n::Backend::Fallbacks
    include I18n::Backend::Pluralization
  end

  def setup
    super
    I18n.backend = I18n::Backend::Chain.new(Backend.new, I18n.backend)
  end

  def test_using_all_features_backend
    assert_equal Backend, I18n.backend.backends.first.class
  end
end

class I18nAllBackendApiBasicsTest < Test::Unit::TestCase
  include AllSetup
  include Tests::Backend::Api::Basics
end

class I18nAllBackendApiTranslateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include AllSetup
  include Tests::Backend::Api::Translation
end

class I18nAllBackendApiInterpolateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include AllSetup
  include Tests::Backend::Api::Interpolation
end

class I18nAllBackendApiLambdaTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include AllSetup
  include Tests::Backend::Api::Lambda
end

class I18nAllBackendApiTranslateLinkedTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include AllSetup
  include Tests::Backend::Api::Link
end

class I18nAllBackendApiPluralizationTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include AllSetup
  include Tests::Backend::Api::Pluralization
end

class I18nAllBackendApiLocalizeDateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include AllSetup
  include Tests::Backend::Api::Localization::Date
end

class I18nAllBackendApiLocalizeDateTimeTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include AllSetup
  include Tests::Backend::Api::Localization::DateTime
end

class I18nAllBackendApiLocalizeTimeTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include AllSetup
  include Tests::Backend::Api::Localization::Time
end

class I18nAllBackendApiLocalizeLambdaTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include Tests::Backend::Simple::Setup::Localization
  include AllSetup
  include Tests::Backend::Api::Localization::Lambda
end


