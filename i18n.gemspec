# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)
require 'i18n/version'

Gem::Specification.new do |s|
  s.name         = "i18n"
  s.version      = I18n::VERSION
  s.authors      = ["Sven Fuchs", "Joshua Harvey", "Matt Aimonetti", "Stephan Soller", "Saimon Moore"]
  s.email        = "rails-i18n@googlegroups.com"
  s.homepage     = "http://github.com/svenfuchs/i18n"
  s.summary      = "New wave Internationalization support for Ruby"
  s.description  = "New wave Internationalization support for Ruby."
  s.license      = "MIT"

  s.files        = Dir.glob("{ci,lib,test}/**/**") + %w(README.textile MIT-LICENSE)
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  s.required_rubygems_version = '>= 1.3.5'

  s.add_development_dependency 'activesupport', '>= 3.0.0'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'test_declarative'
end
