require 'test_helper'

class I18nMiddlewareTest < I18n::TestCase
  def setup
    super
    I18n.default_locale = :fr
    @app = DummyRackApp.new
    @middleware = I18n::Middleware.new(@app)
  end

  test "middleware initializes new config object after request" do
    old_i18n_config_object_id = if Fiber.respond_to?(:[])
      Fiber[:i18n_config].object_id
    else
      Thread.current.thread_variable_get(:i18n_config).object_id
    end
    @middleware.call({})

    updated_i18n_config_object_id = if Fiber.respond_to?(:[])
      Fiber[:i18n_config].object_id
    else
      Thread.current.thread_variable_get(:i18n_config).object_id
    end
    refute_equal updated_i18n_config_object_id, old_i18n_config_object_id
  end

  test "successfully resets i18n locale to default locale by defining new config" do
    @middleware.call({})

    assert_equal :fr, I18n.locale
  end
end
