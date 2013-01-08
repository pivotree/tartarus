lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'tartarus/version'

Gem::Specification.new do |s|
  s.name = %q{tartarus}
  s.version = Tartarus::VERSION
  s.platform    = Gem::Platform::RUBY 

  s.authors = ["Daniel Insley"]
  s.description = %q{Provides exception logging and a generator for creating a clean interface to manage exceptions.}
  s.email = %q{dinsley@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.homepage = %q{http://github.com/dinsley/tartarus}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Exception Logging for Rails}

  s.files         = `git ls-files`.split("\n")  
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")  
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }  

  s.add_runtime_dependency(%q<rails>, [">= 3.0.0"])
  s.add_runtime_dependency(%q<will_paginate>, ["~> 3.0.0"])
  s.add_runtime_dependency(%q<json>, ["~> 1.4"])
end
