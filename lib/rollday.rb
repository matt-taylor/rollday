# frozen_string_literal: true

require "rollday/version"
require "faraday"
require "rollday/configuration"
require "rollday/middleware"

module Rollday
  class Error < StandardError; end
  class Faraday < Error; end # used to create backtrace for rollbar
  class ConfigError < Error; end

  FARADAY_NAME = :rollday.freeze

  def self.configure
    yield configuration if block_given?
  end

  def self.configuration
    @configuration ||= Rollday::Configuration.new
  end

  class << self
    alias_method :config, :configuration
  end

  def self.configuration=(object)
    raise ConfigError, "Expected configuration to be a Rollday::Configuration" unless object.is_a?(Rollday::Configuration)

    @configuration = object
  end

  def self.use_middleware!

  end

  def self.use_default_middleware!
    Rollday::UseMiddleware.use_default_middleware!
  end

  def self.use_default_client_middleware!
    Rollday::UseMiddleware.use_default_client_middleware!
  end

  def self.with_scope()
  end
end
