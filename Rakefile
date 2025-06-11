require "rake"
require "rake/testtask"
require "standard/rake"
require "bundler/gem_tasks"

task default: %i[test standard]

task format: :"standard:fix"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

namespace :test do
  desc "Run tests with acceptance test logging enabled"
  task :debug do
    ENV["ACCEPTANCE_TEST_LOGS"] = "1"
    Rake::Task["test"].invoke
  end
end
