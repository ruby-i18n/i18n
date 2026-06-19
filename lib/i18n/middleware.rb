# frozen_string_literal: true

module I18n
  class Middleware

    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    ensure
      if Fiber.respond_to?(:[])
        Fiber[:i18n_config] = I18n::Config.new
      else
        Thread.current.thread_variable_set(:i18n_config, I18n::Config.new)
      end
    end

  end
end
