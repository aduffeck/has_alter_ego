require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require "rake/gempackagetask"

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the has_alter_ego plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the has_alter_ego plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Schizophrenia'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rake::GemPackageTask.new(eval(File.read("has_alter_ego.gemspec"))) { |pkg| }