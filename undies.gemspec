# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "undies/version"

Gem::Specification.new do |s|
  s.name        = "undies"
  s.version     = Undies::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kelly D. Redding"]
  s.email       = ["kelly@kelredd.com"]
  s.homepage    = "http://github.com/kelredd/undies"
  s.summary     = %q{A pure-Ruby HTML templating DSL.}
  s.description = %q{A pure-Ruby HTML templating DSL.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("bundler", ["~> 1.0"])
  s.add_development_dependency("test-belt", ["~> 2.0"])

end
