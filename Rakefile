require 'rake/clean'
require 'bundler/gem_tasks'
require 'rubygems/tasks'
require 'rspec/core/rake_task'

task :default => [:spec]

# Use default rspec rake task
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

# Configure `rake clobber` to delete all generated files
CLOBBER.include('pkg', 'doc', 'coverage', '*.gem')

Gem::Tasks.new
