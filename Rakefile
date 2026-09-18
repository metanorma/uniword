# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

Dir.glob("lib/tasks/*.rake").sort.each { |task| import task }

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb"]
  t.options = ["--markup", "markdown", "--output-dir", "docs/api"]
end

desc "Run RuboCop"
task :rubocop do
  sh "bundle exec rubocop -A --auto-gen-config"
end

desc "Run tests"
task default: :spec

desc "Open console with gem loaded"
task :console do
  require "irb"
  require "uniword"
  ARGV.clear
  IRB.start
end
