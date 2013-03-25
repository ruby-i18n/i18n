require 'test_helper'

class I18nMissingInterpolationHandlerTest < Test::Unit::TestCase
  test "#call raises an exception by default" do
    subject = I18n::MissingInterpolationArgumentHandler.new
    assert_raise(I18n::MissingInterpolationArgument) { subject.call(1, 2, 3) }
  end

  def mock_exception(method_name, return_value)
    mock('exception').tap do |e|
      e.expects(method_name).returns(return_value)
    end
  end

  test "#call returns html message when :raise_exception option is false" do
    exception = mock_exception(:html_message, 'missing!')
    I18n::MissingInterpolationArgument.expects(:new).with(1, 2, 3).returns(exception)

    subject = I18n::MissingInterpolationArgumentHandler.new(:raise_exception => false)
    assert_equal 'missing!', subject.call(1, 2, 3)
  end

  test "#call returns plain text message when :rescue_format option is :text" do
    exception = mock_exception(:message, 'missing!')
    I18n::MissingInterpolationArgument.expects(:new).with(1, 2, 3).returns(exception)

    subject = I18n::MissingInterpolationArgumentHandler.new(:raise_exception => false, :rescue_format => :text)
    assert_equal '<missing!>', subject.call(1, 2, 3)
  end
end
