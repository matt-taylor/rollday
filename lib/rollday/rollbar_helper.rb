# frozen_string_literal: true

require 'rollbar'

module Rollday
  module RollbarHelper

    def rollbar_level(result)
      level = Rollday.config.rollbar_level
      level.is_a?(Proc) ? level.(result.status) : level
    end

    def rollbar_message(result)
      message = Rollday.config.message.(result.status, result.reason_phrase, result.body, URI(result.env.url).path, URI(result.env.url).host)
      return message unless Rollday.config.use_message_exception

      Rollday.config.exception_class.new(message)
    end

    def rollbar_scope(result)
      {
        framework: "Faraday: #{::Faraday::VERSION}; Rollday: #{Rollday::VERSION}",
        host: URI(result.env.url).host,
        method: result.env.method,
        params: params_scope(result),
        path: URI(result.env.url).path,
        body: result.body,
        person: person_scope,
        query: query_scope(result),
        status: result.status,
        status_phrase: result.reason_phrase,
      }
    end

    private

    def query_scope(result)
      return {} unless  Rollday.config.use_query_scope
      raw_query = URI(result.env.url).query
      return if raw_query.nil?

      query_scope = CGI::parse(raw_query)
      Rollday.config.params_scope_sanitizer.each do |sanitizer|
        query_scope = sanitizer.(query_params)
      end

      query_scope
    end

    def params_scope(result)

    end

    def person_scope
      Rollday.config.person_scope.()
    end
  end
end
