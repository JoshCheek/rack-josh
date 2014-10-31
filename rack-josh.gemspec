# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack/josh/version"

Gem::Specification.new do |s|
  s.name        = "rack-josh"
  s.version     = Rack::Josh::VERSION
  s.authors     = ["Josh Cheek"]
  s.email       = ["josh.cheek@gmail.com"]
  s.homepage    = "https://github.com/JoshCheek/rack-josh"
  s.summary     = %q{Rack middleware I find myself wanting}
  s.description = %q{Rack middleware I find myself or rebuilding frequently}
  s.license     = "WTFPL"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "rack-test", "~> 0.6.0"
  s.add_development_dependency "rspec",     "~> 3.1.0"
end
