# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "undies/version"

Gem::Specification.new do |s|
  s.name        = "undies"
  s.version     = Undies::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kelly Redding"]
  s.email       = ["kelly@kelredd.com"]
  s.homepage    = "http://github.com/kelredd/undies"
  s.summary     = %q{A pure-Ruby DSL for streaming templated HTML, XML, or plain text. Named for its gratuitous use of the underscore.}
  s.description = %q{A pure-Ruby DSL for streaming templated HTML, XML, or plain text. Named for its gratuitous use of the underscore.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("bundler", ["~> 1.0"])
  s.add_development_dependency("assert", ["~> 0.7.3"])
  s.add_development_dependency("assert-view", ["~> 0.6"])
  s.add_development_dependency("whysoslow", ["~> 0.0"])

end
