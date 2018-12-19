# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)
require 'i18n/version'

Gem::Specification.new do |s|
  s.name         = "i18n"
  s.version      = I18n::VERSION
  s.authors      = ["Sven Fuchs", "Joshua Harvey", "Matt Aimonetti", "Stephan Soller", "Saimon Moore", "Ryan Bigg"]
  s.email        = "rails-i18n@googlegroups.com"
  s.homepage     = "http://github.com/svenfuchs/i18n"
  s.summary      = "New wave Internationalization support for Ruby"
  s.description  = "New wave Internationalization support for Ruby."
  s.license      = "MIT"

  s.metadata     = {
                     'bug_tracker_uri'   => 'https://github.com/svenfuchs/i18n/issues',
                     'changelog_uri'     => 'https://github.com/svenfuchs/i18n/releases',
                     'documentation_uri' => 'https://guides.rubyonrails.org/i18n.html',
                     'source_code_uri'   => 'https://github.com/svenfuchs/i18n',
                   }

  s.files        = Dir.glob("lib/**/*") + %w(README.md MIT-LICENSE)
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  s.required_rubygems_version = '>= 1.3.5'
  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'concurrent-ruby', '~> 1.0'

  s.post_install_message = <<-END

HEADS UP! i18n 1.1 changed fallbacks to exclude default locale.
But that may break your application.

Please check your Rails app for 'config.i18n.fallbacks = true'.
If you're using I18n (>= 1.1.0) and Rails (< 5.2.2), this should be
'config.i18n.fallbacks = [I18n.default_locale]'.
If not, fallbacks will be broken in your app by I18n 1.1.x.

For more info see:
https://github.com/svenfuchs/i18n/releases/tag/v1.1.0

END

end
