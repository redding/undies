# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "undies/version"

Gem::Specification.new do |gem|
  gem.name        = "undies"
  gem.version     = Undies::VERSION
  gem.authors     = ["Kelly Redding"]
  gem.email       = ["kelly@kellyredding.com"]
  gem.description = %q{A pure-Ruby DSL for streaming templated HTML, XML, or plain text.}
  gem.summary     = %q{A pure-Ruby DSL for streaming templated HTML, XML, or plain text.}
  gem.homepage    = "http://github.com/kellyredding/undies"
  gem.license     = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert")

end
