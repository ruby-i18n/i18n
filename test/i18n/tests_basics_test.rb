require 'test_helper'

class I18nTestsBasicsTest < I18n::TestCase
  test "the shared API tests call the teardown of the test case including them" do
    torn_down = false
    test_case = Class.new(Minitest::Test) { define_method(:teardown) { torn_down = true } }
    api_test = Class.new(test_case) { include I18n::Tests::Basics }
    Minitest::Runnable.runnables.delete(test_case)
    Minitest::Runnable.runnables.delete(api_test)

    api_test.new(api_test.runnable_methods.first).run
    assert torn_down
  end
end
