# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_rest/version'

Gem::Specification.new do |spec|
  spec.name          = "active_rest"
  spec.version       = ActiveRest::VERSION
  spec.authors       = ["Allan Batista", "Leonardo Teixeira"]
  spec.email         = ["allan@allanbatista.com.br", "leorodriguesrj@gmail.com"]
  spec.summary       = "teste"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug"
  
  spec.add_dependency "faraday"
  spec.add_dependency "activesupport"
end
