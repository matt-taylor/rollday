# frozen_string_literal: true

require 'rollbar'

module Rollday
  module RollbarHelper

    def rollbar_level(result)
      level = Rollday.config.rollbar_level
      level.is_a?(Proc) ? level.call(result.status) : level
    end

    def rollbar_message(result)
      message = Rollday.config.message.call(result.status, result.reason_phrase, URI(result.env.url).host)
      return message unless Rollday.config.use_message_exception

      Rollday::Faraday.new(message)
    end

    def rollbar_scope(result)
      {
        host: URI(result.env.url).host,
        framework: "Faraday: #{::Faraday::VERSION}; Rollday: #{Rollday::VERSION}",
        method: result.env.method,
        params: params_scope(result),
        person: person_scope,
        query: query_scope(result),
        status: result.status,
        status_phrase: result.reason_phrase,
      }
    end

    private

    def query_scope(result)
      return {} unless  Rollday.config.use_query_scope

      query_params = CGI::parse(URI(result.env.url).query)
      Rollday.config.params_scope_sanitizer.each do |sanitizer|
        query_params = sanitizer.call(query_params)
      end

      query_params
    end

    def params_scope(result)

    end

    def person_scope
      Rollday.config.person_scope.()
    end
  end
end
