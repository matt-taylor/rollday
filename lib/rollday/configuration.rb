# frozen_string_literal: true

require "rollday/use_middleware"
require "rollbar"
require "class_composer"

module Rollday
  class Configuration
    include ClassComposer::Generator

    ROLLBAR_LEVELS = [
      DEBUG = :debug,
      INFO = :info,
      WARNING = :warning,
      ERROR = :error,
      CRITICAL = :critical
    ]

    DEFAULT_STATUS_CODE_REGEX = /[45]\d\d$/
    DEFAULT_MESSAGE_PROC = ->(status, phrase, body, path, domain) { "[#{status}]: #{domain} - #{path}" }
    DEFAULT_LEVEL_PROC = ->(_status) { WARNING }
    ROLLBAR_VALIDATOR = Proc.new do |value|
      value.is_a?(Proc) || ROLLBAR_LEVELS.include?(value)
    end

    add_composer :message, allowed: [Proc, String], default: DEFAULT_MESSAGE_PROC
    add_composer :params_query_sanitizer, allowed: Array, default: []
    add_composer :params_scope_sanitizer, allowed: Array, default: []
    add_composer :status_code_regex, allowed: Regexp, default: DEFAULT_STATUS_CODE_REGEX
    add_composer :use_message_exception, allowed: [TrueClass, FalseClass], default: true
    add_composer :use_params_scope, allowed: [TrueClass, FalseClass], default: true
    add_composer :use_person_scope, allowed: [TrueClass, FalseClass], default: true
    add_composer :use_query_scope, allowed: [TrueClass, FalseClass], default: true
    add_composer :rollbar_level, allowed: [Proc, Symbol], default: DEFAULT_LEVEL_PROC, validator: ROLLBAR_VALIDATOR, invalid_message: -> (val) { "Value must be a Proc or one of #{ROLLBAR_LEVELS}" }

    def person_scope
      return -> {} unless @use_person_scope

      @person_scope || Rollbar.scope.scope_object.raw[:person] || -> {}
    end

    def use_default_middleware!
      Rollday.use_default_middleware!
    end

    def use_default_client_middleware!
      Rollday.use_default_client_middleware!
    end
  end
end
