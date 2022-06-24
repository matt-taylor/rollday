# frozen_string_literal: true

require "rollday/use_middleware"
require "rollbar"

module Rollday
  class Configuration
    ROLLBAR_LEVELS = [
      DEBUG = :debug,
      INFO = :info,
      WARNING = :warning,
      ERROR = :error,
      CRITICAL = :critical
    ]

    DEFAULT_STATUS_CODE_REGEX = /[45]\d\d$/
    DEFAULT_MESSAGE_PROC = ->(status, phrase, domain) { "[#{status}]: #{domain}" }
    DEFAULT_LEVEL_PROC = ->(_status) { WARNING }

    attr_accessor :use_person_scope, :use_params_scope, :params_scope_sanitizer, :use_query_scope, :params_query_sanitizer, :use_message_exception

    def initialize(options = {})
      @status_code_regex = DEFAULT_STATUS_CODE_REGEX
      @use_person_scope = true

      @use_params_scope = true
      @params_scope_sanitizer = []

      @use_query_scope = true
      @params_query_sanitizer = []

      @message = DEFAULT_MESSAGE_PROC
      @use_message_exception = true

      @rollbar_level = DEFAULT_LEVEL_PROC
    end

    def rollbar_level=(level)
      raise ConfigError, "level= must be passed a Proc or #{ROLLBAR_LEVELS}. But was passed a #{level} instead"

      @rollbar_level = level
    end

    def rollbar_level
      @rollbar_level
    end

    def message=(message)
      raise ConfigError, "message= must be passed a Proc but was passed a #{message.class} instead"

      @message = message
    end

    def message
      @message
    end

    def status_code_regex
      @status_code_regex
    end

    def status_code_regex=(regex)
      raise ConfigError, "status_code_regex= must be passed a regex but was passed a #{regex.class} instead"

      @status_code_regex = regex
    end

    def person_scope=(person_scope)
      raise ConfigError, "person_scope= must be passed a Proc but was passed a #{person_scope.class} instead"

      @person_scope = person_scope
    end

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
