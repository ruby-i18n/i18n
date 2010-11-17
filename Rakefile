require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = "#{File.dirname(__FILE__)}/test/all.rb"
  t.verbose = true
  t.warning = true
end
Rake::Task['test'].comment = "Run all i18n tests"

# require "rake/gempackagetask"
# require "rake/clean"
# CLEAN << "pkg" << "doc" << "coverage" << ".yardoc"
#
# Rake::GemPackageTask.new(eval(File.read("i18n.gemspec"))) { |pkg| }
#
# begin
#   require "yard"
#   YARD::Rake::YardocTask.new do |t|
#     t.options = ["--output-dir=doc"]
#     t.options << "--files" << ["CHANGELOG.textile", "contributors.txt", "MIT-LICENSE"].join(",")
#   end
# rescue LoadError
# end
