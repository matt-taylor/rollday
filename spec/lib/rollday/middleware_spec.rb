# frozen_string_literal: true

RSpec.describe Rollday::Middleware do
  before do
    Rollday.reset_configuration!
  end

  let(:base_url) { "http://httpstat.us" }

  shared_examples "Rollbar Middleware" do |receive_rollbar|
    let(:message_type) { Rollday.config.use_message_exception ? Rollday::Faraday : String }
    if receive_rollbar
      it "reports to rollbar" do
        # At least once is needd for Default Client
        # Default (Faraday.get etc) cannot be modifed after the Client has been created
        # Meaning it can not be modified -- The default client instance injects middleware to the builder when it gets called
        # Causing the middleware to get pushed to Faraday twice when both are used
        expect(::Rollbar).to receive(:log).with(rollbar_level, be_a(message_type), be_a(Hash)).at_least(:once)

        subject
      end
    else
      it "does not report to rollbar" do
        expect(::Rollbar).to_not receive(:log)

        subject
      end
    end
  end

  describe "Using Default Faraday client" do
    subject { Faraday.get("#{base_url}/#{status_code}") }

    context "with default config" do
      before do
        Rollday.use_default_middleware!
      end

      context "with 2xx" do
        let(:status_code) { Faker::Number.between(from: 200, to: 300) }

        include_examples "Rollbar Middleware", false
      end

      context "with 3xx" do
        let(:status_code) { Faker::Number.between(from: 300, to: 400) }

        include_examples "Rollbar Middleware", false
      end

      context "with 4xx" do
        let(:status_code) { Faker::Number.between(from: 400, to: 500) }
        let(:rollbar_level) { Rollday::Configuration::DEFAULT_ROLLBAR_LEVEL }

        include_examples "Rollbar Middleware", true
      end

      context "with 5xx" do
        let(:status_code) { Faker::Number.between(from: 500, to: 600) }
        let(:rollbar_level) { Rollday::Configuration::DEFAULT_ROLLBAR_LEVEL }

        include_examples "Rollbar Middleware", true
      end
    end

    context "with custom config" do
      before do
        Rollday.use_default_middleware!
        Rollday.configure do |c|
          c.status_code_regex = /[2345]\d\d$/
          c.rollbar_level = ->(status) { status.to_s[0].to_i <= 3 ? Rollday::Configuration::DEBUG : Rollday::Configuration::CRITICAL }
          c.use_message_exception = false
        end
      end

      context "with 2xx" do
        let(:status_code) { Faker::Number.between(from: 200, to: 300) }
        let(:rollbar_level) { Rollday::Configuration::DEBUG }

        include_examples "Rollbar Middleware", true
      end

      context "with 3xx" do
        let(:status_code) { Faker::Number.between(from: 300, to: 400) }
        let(:rollbar_level) { Rollday::Configuration::DEBUG }

        include_examples "Rollbar Middleware", true
      end

      context "with 4xx" do
        let(:status_code) { Faker::Number.between(from: 400, to: 500) }
        let(:rollbar_level) { Rollday::Configuration::CRITICAL }

        include_examples "Rollbar Middleware", true
      end

      context "with 5xx" do
        let(:status_code) { Faker::Number.between(from: 500, to: 600) }
        let(:rollbar_level) { Rollday::Configuration::CRITICAL }

        include_examples "Rollbar Middleware", true
      end
    end
  end

  describe "Using Faraday client instance" do
    subject { client.get(status_code.to_s) }

    before do
      Rollday.use_default_client_middleware!
    end

    let(:client) { Faraday.new(url: base_url) }

    context "with default config" do
      context "with 2xx" do
        let(:status_code) { Faker::Number.between(from: 200, to: 300) }

        include_examples "Rollbar Middleware", false
      end

      context "with 3xx" do
        let(:status_code) { Faker::Number.between(from: 300, to: 400) }

        include_examples "Rollbar Middleware", false
      end

      context "with 4xx" do
        let(:status_code) { Faker::Number.between(from: 400, to: 500) }
        let(:rollbar_level) { Rollday::Configuration::DEFAULT_ROLLBAR_LEVEL }

        include_examples "Rollbar Middleware", true
      end

      context "with 5xx" do
        let(:status_code) { Faker::Number.between(from: 500, to: 600) }
        let(:rollbar_level) { Rollday::Configuration::DEFAULT_ROLLBAR_LEVEL }

        include_examples "Rollbar Middleware", true
      end
    end

    context "with custom config" do
      before do
        Rollday.use_default_middleware!
        Rollday.configure do |c|
          c.status_code_regex = /[2345]\d\d$/
          c.rollbar_level = ->(status) { status.to_s[0].to_i <= 3 ? Rollday::Configuration::DEBUG : Rollday::Configuration::CRITICAL }
          c.use_message_exception = false
        end
      end

      context "with 2xx" do
        let(:status_code) { Faker::Number.between(from: 200, to: 300) }
        let(:rollbar_level) { Rollday::Configuration::DEBUG }

        include_examples "Rollbar Middleware", true
      end

      context "with 3xx" do
        let(:status_code) { Faker::Number.between(from: 300, to: 400) }
        let(:rollbar_level) { Rollday::Configuration::DEBUG }

        include_examples "Rollbar Middleware", true
      end

      context "with 4xx" do
        let(:status_code) { Faker::Number.between(from: 400, to: 500) }
        let(:rollbar_level) { Rollday::Configuration::CRITICAL }

        include_examples "Rollbar Middleware", true
      end

      context "with 5xx" do
        let(:status_code) { Faker::Number.between(from: 500, to: 600) }
        let(:rollbar_level) { Rollday::Configuration::CRITICAL }

        include_examples "Rollbar Middleware", true
      end
    end

    context "with passed in middleware" do
      let(:client) do
        Faraday.new(url: base_url) do |conn|
          conn.use Rollday::MIDDLEWARE_NAME
        end
      end

      before do
        Rollday.register_middleware!
        Rollday.configure do |c|
          c.allow_client_middleware = false
          c.status_code_regex = /[2345]\d\d$/
        end
      end

      let(:rollbar_level) { Rollday::Configuration::DEFAULT_ROLLBAR_LEVEL }

      context "with 2xx" do
        let(:status_code) { Faker::Number.between(from: 200, to: 300) }

        include_examples "Rollbar Middleware", true
      end

      context "with 3xx" do
        let(:status_code) { Faker::Number.between(from: 300, to: 400) }

        include_examples "Rollbar Middleware", true
      end

      context "with 4xx" do
        let(:status_code) { Faker::Number.between(from: 400, to: 500) }

        include_examples "Rollbar Middleware", true
      end

      context "with 5xx" do
        let(:status_code) { Faker::Number.between(from: 500, to: 600) }

        include_examples "Rollbar Middleware", true
      end
    end
  end
end
