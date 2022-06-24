# frozen_string_literal: true

require "faraday"
require "rollday/rollbar_helper"

module Rollday
  class Middleware < Faraday::Middleware
    include RollbarHelper

    def initialize(app, **)
      super(app)

      @app = app
    end

    def call(env)
      result = @app.(env)
      if ship_to_rollbar?(result.status)
        send_rollbar(result)
      end

      result
    end

    private

    def ship_to_rollbar?(status)
      status.to_s =~ Rollday.config.status_code_regex
    end

    def send_rollbar(result)
      scope = rollbar_scope(result)
      message = rollbar_message(result)
      level = rollbar_level(result)
      ::Rollbar.log(level, message, **scope)
    end
  end
end
