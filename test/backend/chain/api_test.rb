require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'i18n/backend/chain'

module ChainSetup
  def setup
    super
    first = I18n::Backend::Simple.new
    # first.store_translations(:en, translations)
    I18n.backend = I18n::Backend::Chain.new(first, I18n.backend)
  end
end

class I18nChainBackendApiBasicsTest < Test::Unit::TestCase
  include ChainSetup
  include Tests::Backend::Api::Basics
end

class I18nChainBackendApiTranslateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include ChainSetup
  include Tests::Backend::Api::Translation
end

class I18nChainBackendApiInterpolateTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include ChainSetup
  include Tests::Backend::Api::Interpolation
end

class I18nChainBackendApiLambdaTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include ChainSetup
  include Tests::Backend::Api::Lambda
end

class I18nChainBackendApiTranslateLinkedTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include ChainSetup
  include Tests::Backend::Api::Link
end

class I18nChainBackendApiPluralizationTest < Test::Unit::TestCase
  include Tests::Backend::Simple::Setup::Base
  include ChainSetup
  include Tests::Backend::Api::Pluralization
end

class I18nChainBackendApiLocalizeDateTest < Test::Unit::TestCase
  include ChainSetup
  include Tests::Backend::Simple::Setup::Localization
  include Tests::Backend::Api::Localization::Date
end

class I18nChainBackendApiLocalizeDateTimeTest < Test::Unit::TestCase
  include ChainSetup
  include Tests::Backend::Simple::Setup::Localization
  include Tests::Backend::Api::Localization::DateTime
end

class I18nChainBackendApiLocalizeTimeTest < Test::Unit::TestCase
  include ChainSetup
  include Tests::Backend::Simple::Setup::Localization
  include Tests::Backend::Api::Localization::Time
end

class I18nChainBackendApiLocalizeLambdaTest < Test::Unit::TestCase
  include ChainSetup
  include Tests::Backend::Simple::Setup::Localization
  include Tests::Backend::Api::Localization::Lambda
end

