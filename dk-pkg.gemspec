# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dk-pkg/version"

Gem::Specification.new do |gem|
  gem.name        = "dk-pkg"
  gem.version     = Dk::Pkg::VERSION
  gem.authors     = ["Kelly Redding", "Collin Redding"]
  gem.email       = ["kelly@kellyredding.com", "collin.redding@me.com"]
  gem.summary     = "Dk logic for installing pkgs"
  gem.description = "Dk logic for installing pkgs"
  gem.homepage    = "https://github.com/redding/dk-pkg"
  gem.license     = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert", ["~> 2.16.3"])

  gem.add_dependency("dk",          ["~> 0.1.0"])
  gem.add_dependency("much-plugin", ["~> 0.2.0"])

end
