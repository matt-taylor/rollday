# frozen_string_literal: true

module Rollday
  module FaradayConnectionOptions
    def new_builder(block)
      super.tap do |builder|
        builder.use(Rollday::FARADAY_NAME)
      end
    end
  end
end
