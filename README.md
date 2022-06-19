# Rollday

Rollday is a a gem to integrate with Faraday requests. It adds a default middleware for your projecrts Faraday client to send a rollbar for configurable response status codes.

It can be configured once for th eentire project, or customized per Faraday request


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rollday'
```

## Usage

### Initialization

Intialization should happen in `app/initializers/rollday.rb`. All options below are the current defaults unless stated
```ruby
Rollay.configure do |config|
  config.use_default_middleware! # [Not default option] set middleware for all Faraday requests

  config.status_code_regex = /[45]\d\d$/ # If status code matches, will attempt to send a rollbar

  config.use_person_scope = true # Assign a person scope to the rollbar scope

  config.use_params_scope = true # Assign a params scope to the rollbar scope. Configured from Faraday params for request

  config.params_scope_sanitizer = [] # Array of Procs to sanitize params. Can remove params or call Rollbar::Scrubbers.scrub_value(*) to assign value

  config.use_query_scope = true # Assign the url queries to the scope

  config.params_query_sanitizer = [] # Array of Procs to sanitize query params. Can remove params or call Rollbar::Scrubbers.scrub_value(*) to assign value

  config.message = ->(status, phrase, domain) { "[#{status}]: #{domain}" } # Message to set for the Rollbar item. Value can be a proc or a static message

  config.use_message_exception = true # When set to true, Exception will be used to establish a backtrace

  config.rollbar_level = ->(_status) { :warning } # Rollbar level can be configurable based on the status code
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake rspec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment. Run `bundle exec rollday` to use
the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version:

1. Update the version number in [lib/rollday/version.rb]
2. Update [CHANGELOG.md]
3. Merge to the main branch. This will trigger an automatic build in CircleCI
   and push the new gem to the repo.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/matt-taylor/rollday.

