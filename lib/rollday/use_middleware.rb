# frozen_string_literal: true

module Rollday
  module UseMiddleware
    def self.use_default_middleware!
      register_middleware!

      return false if @add_default_middleware

      idx = ::Faraday.default_connection.builder.handlers.size - 1
      ::Faraday.default_connection.builder.insert(idx, Middleware)
      @add_default_middleware = true
    end

    def self.register_middleware!
      return false if @register_middleware

      ::Faraday::Middleware.register_middleware(rollday: Middleware)
      @register_middleware = true
    end
  end
end
