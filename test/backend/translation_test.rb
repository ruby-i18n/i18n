require 'test_helper'

class I18nBackendTranslationTest < Test::Unit::TestCase
  def attributes
    { :locale => :en,
      :key => 'foo.bar',
      :scope => 'baz.biz',
      :default => 'default text',
      :custom_1 => 'interpolation 1',
      :custom_2 => 'interpolation 2'
    }
  end

  test "it initializes attributes" do
    translation = I18n::Backend::Translation.new(attributes)
    assert_equal(:en, translation.locale)
    assert_equal('foo.bar', translation.key)
    assert_equal('baz.biz', translation.scope)
    assert_equal({:custom_1 => 'interpolation 1', :custom_2 => 'interpolation 2'}, translation.interpolations)
    assert_nil(translation.content)
  end

  test "it strips RESERVED_KEYS from interpolations upon initialization" do
    reserved_keys_hash = {}
    I18n::RESERVED_KEYS.each {|key| reserved_keys_hash[key] = key }
    translation = I18n::Backend::Translation.new(attributes.merge(reserved_keys_hash))
    assert_equal({:custom_1 => 'interpolation 1', :custom_2 => 'interpolation 2'}, translation.interpolations)
  end

  test "#count returns the value of interpolations[:count]" do
    translation = I18n::Backend::Translation.new(attributes.merge(:count => 2))
    assert_equal(2, translation.count)
  end

  test "#context returns the value of interpolations[:context]" do
    translation = I18n::Backend::Translation.new(attributes.merge(:context => 'a context'))
    assert_equal('a context', translation.context)
    assert_equal('a context', translation.interpolations[:context])
  end
end