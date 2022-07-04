# frozen_string_literal: true

module Rollday
  class Error < StandardError; end
  class Faraday < Error; end # used to create backtrace for rollbar
  class ConfigError < Error; end
end
