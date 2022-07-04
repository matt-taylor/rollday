# frozen_string_literal: true

require "faraday"
require "rollday/configuration"
require "rollday/errors"
require "rollday/middleware"
require "rollday/version"

module Rollday
  FARADAY_NAME = :rollday.freeze

  def self.configure
    yield configuration if block_given?
  end

  def self.configuration
    @configuration ||= Rollday::Configuration.new
  end

  def self.configuration=(object)
    raise ConfigError, "Expected configuration to be a Rollday::Configuration" unless object.is_a?(Rollday::Configuration)

    @configuration = object
  end

  def self.reset_configuration!
    @configuration = Rollday::Configuration.new
  end

  class << self
    alias_method :config, :configuration
    alias_method :config=, :configuration=
    alias_method :reset_config!, :reset_configuration!
  end

  def self.use_default_middleware!
    Rollday::UseMiddleware.use_default_middleware!
  end

  def self.use_default_client_middleware!
    Rollday::UseMiddleware.use_default_client_middleware!
  end

  def self.register_middleware!
    Rollday::UseMiddleware.register_middleware!
  end

  def self.with_scope()
  end
end
