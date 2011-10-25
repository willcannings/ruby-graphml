# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby-graphml"

Gem::Specification.new do |s|
  s.name        = "ruby-graphml"
  s.version     = GraphML::VERSION
  s.authors     = ["Will"]
  s.email       = ["me@willcannings.com"]
  s.homepage    = ""
  s.summary     = %q{Ruby GraphML Parser}
  s.description = %q{Ruby GraphML Parser}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "nokogiri"
end
