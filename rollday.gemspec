# frozen_string_literal: true

require_relative "lib/rollday/version"

Gem::Specification.new do |spec|
  spec.name    = "rollday"
  spec.version = Rollday::VERSION
  spec.authors = ["Matt Taylor"]
  spec.email   = ["mattius.taylor@gmail.com"]

  spec.summary     = "This is a hybrid mutant of Faraday and Rollbar. Inject Rollbar into Customized Faraday returns"
  spec.description = "Add Rollbar to Faraday middleware easily and customizable"
  spec.homepage    = "https://github.com/matt-taylor/rollday"
  spec.license     = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.7")

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    %x(git ls-files -z).split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "class_composer"
  spec.add_dependency "faraday"
  spec.add_dependency "rollbar"

  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.17.0"
end
