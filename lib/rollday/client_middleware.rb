# frozen_string_literal: true

module Rollday
  module FaradayConnectionOptions
    def new_builder(block)
      super.tap do |builder|
        # allow scope to remove usage of middleware for a request
        # after it has been injected into the Connection
        if Rollday.config.allow_client_middleware
          builder.use(Rollday::MIDDLEWARE_NAME)
        end
      end
    end
  end
end
