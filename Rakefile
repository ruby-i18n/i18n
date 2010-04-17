require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new(:test) do |t|
  t.pattern = "#{File.dirname(__FILE__)}/test/all.rb"
  t.verbose = true
end
Rake::Task['test'].comment = "Run all i18n tests"