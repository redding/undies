# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "undies/version"

Gem::Specification.new do |s|
  s.name        = "undies"
  s.version     = Undies::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = "http://github.com/__/undies"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("bundler", ["~> 1.0"])
  s.add_development_dependency("test-belt", ["= 1.0.1"]) # TODO: lock to a specific version for test stability
  # s.add_dependency("gem-name", ["~> 0.0"])
end
