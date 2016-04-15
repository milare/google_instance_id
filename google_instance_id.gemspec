# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_instance_id/version'

Gem::Specification.new do |spec|
  spec.name          = "google_instance_id"
  spec.version       = GoogleInstanceId::VERSION
  spec.authors       = ["Bruno Milare"]
  spec.email         = ["milare@gmail.com"]

  spec.summary       = %q{Google Instance ID}
  spec.description   = %q{Implements Google Instance ID}
  spec.homepage      = "http://github.com/milare/instance_id"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"

  spec.add_dependency('httparty')
  spec.add_dependency('json')
  spec.add_dependency('hashie')
end
