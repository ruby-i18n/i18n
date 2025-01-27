require 'test_helper'

class I18nBackendDeprecatorTest < I18n::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Deprecator
    include I18n::Backend::Fallbacks
  end

  def setup
    super
    I18n.backend = Backend.new
    I18n.deprecate(old_key: :new_key)
  end

  test 'old key defined, new key undefined' do
    store_translations(:xx, old_key: 'Hello world')

    assert_equal 'Hello world', I18n.t(:old_key, locale: :xx)
    assert_equal 'Hello world', I18n.t(:new_key, locale: :xx)
  end

  test 'old key undefined, new key defined' do
    store_translations(:xx, new_key: 'Hello new world')

    assert_equal 'Hello new world', I18n.t(:old_key, locale: :xx)
    assert_equal 'Hello new world', I18n.t(:new_key, locale: :xx)
  end

  test 'old key defined, new key defined' do
    store_translations(:xx, old_key: 'Hello world', new_key: 'Hello new world')

    assert_equal 'Hello world', I18n.t(:old_key, locale: :xx)
    assert_equal 'Hello world', I18n.t(:new_key, locale: :xx)
  end
end
