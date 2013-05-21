require "bundler/gem_tasks"
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color"
end

RSpec::Core::RakeTask.new(:spec_doc) do |t|
  t.rspec_opts = "--color --format doc"
end


task :default => :spec
