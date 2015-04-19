# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kaya/version'

Gem::Specification.new do |spec|
  spec.name                   = "kaya"
  spec.version                = Kaya::VERSION
  spec.authors                = ["Roman Rodriguez"]
  spec.email                  = ["roman.g.rodriguez@gmail.com"]
  spec.summary                = %q{Exposes Cucumber suites in a web service to make them run}
  spec.description            = %q{You can run your cucumber suites easily, save and see the execution results}
  spec.homepage               = "http://qqq.akjsdh"
  spec.license                = "MIT"
  spec.required_ruby_version  = ">= 2.0.0"

  spec.files                  = `git ls-files -z`.split("\x0")
  spec.executables            = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files             = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths          = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'cuba'
  spec.add_dependency 'unicorn'
  spec.add_dependency 'mongodb'
  spec.add_dependency 'redis'
  spec.add_dependency 'sidekiq'
  spec.add_dependency 'bson_ext'
  spec.add_dependency 'syntax'
  spec.add_dependency 'colorize'
  spec.add_dependency 'github-markup'
  spec.add_dependency 'redcarpet'
  spec.add_dependency 'gmail'
  spec.add_dependency 'mote'



  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cucumber"
end
