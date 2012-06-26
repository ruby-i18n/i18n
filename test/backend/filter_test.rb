require 'test_helper'

class I18nBackendFilterTest < Test::Unit::TestCase
  test "it has a writeable translation attribute" do
    filter = I18n::Backend::Filter.new(:translation)
    filter.translation = :modified
    assert_equal :modified, filter.translation
  end

  test "it has a readable context attribute" do
    filter = I18n::Backend::Filter.new(:translation, :context)
    assert_equal :context, filter.context
  end

  test "#applicable? raises a NotImplementedError" do
    filter = I18n::Backend::Filter.new(:translation)
    assert_raise(NotImplementedError) { filter.applicable? }
  end

  test "#call raises a NotImplementedError" do
    filter = I18n::Backend::Filter.new(:translation)
    assert_raise(NotImplementedError) { filter.call }
  end
end