# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'upyun/version'

Gem::Specification.new do |spec|
  spec.name          = "upyun"
  spec.version       = UpYun::VERSION
  spec.authors       = ["jsvisa"]
  spec.email         = ["delweng@gmail.com"]
  spec.summary       = "Upyun API SDK"
  spec.description   = "UpYun API SDK"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client", ">= 1.6.7"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
end

