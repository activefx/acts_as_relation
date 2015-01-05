require 'bundler/setup'
require 'rake'
require 'rspec/core/rake_task'

desc 'Run specs'
RSpec::Core::RakeTask.new

namespace :test do
  desc 'Run entire test suite'
  task :suite do
    system("appraisal rake spec")
  end
end

# task :default => :spec
task default: [ 'test:suite' ]
