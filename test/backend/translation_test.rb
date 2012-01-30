require 'test_helper'

class I18nBackendTranslationTest < Test::Unit::TestCase
  def attributes
    { :locale => :en,
      :key => 'foo.bar',
      :scope => 'baz.biz',
      :count => 2,
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
    assert_equal(2, translation.count)
    assert_equal({:custom_1 => 'interpolation 1', :custom_2 => 'interpolation 2'}, translation.options)
    assert_nil(translation.content)
  end
end