require 'rubygems'
require 'rake'
require 'bundler'

Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ['--color', '--format progress']
  spec.pattern = 'spec/**/*_spec.rb'
#  spec.rcov = true
#  spec.rcov_opts = lambda do
#    IO.readlines("spec/rcov.opts").map { |l| l.chomp.split " " }.flatten
#  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tartarus #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
