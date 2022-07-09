# frozen_string_literal: true

module Rollday
  module UseMiddleware
    # https://github.com/lostisland/faraday/blob/816d824bc18453e86027c9c5fcf8427020566e50/lib/faraday/rack_builder.rb#L83-L86
    # https://github.com/lostisland/faraday/blob/816d824bc18453e86027c9c5fcf8427020566e50/lib/faraday/rack_builder.rb#L156-L169
    # Once the default middleware is crated and the Faraday Rack app has been built,
    # it can not be removed from the middleware Faraday stack
    # If removal is needed, then use the middleware per request instead of defaulted
    # or use the `with_scope` to modify the parameters of the rollday gem
    def self.use_default_middleware!
      register_middleware!

      return false if @add_default_middleware

      idx = ::Faraday.default_connection.builder.handlers.size - 1
      ::Faraday.default_connection.builder.insert(idx, Middleware)
      @add_default_middleware = true
    end

    # https://github.com/lostisland/faraday/issues/946#issuecomment-500607890
    # Monkey patch to force this middleware into every single Faraday.new client
    def self.use_default_client_middleware!
      return false if @use_default_client_middleware

      register_middleware!
      require "rollday/client_middleware"
      ::Faraday::ConnectionOptions.prepend(Rollday::FaradayConnectionOptions)

      @use_default_client_middleware = true
    end

    def self.register_middleware!
      return false if @register_middleware

      ::Faraday::Middleware.register_middleware(Rollday::MIDDLEWARE_NAME => Middleware)
      @register_middleware = true
    end
  end
end
