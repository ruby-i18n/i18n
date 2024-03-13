source 'https://rubygems.org'

gemspec :path => '..'

gem 'activesupport', '~> 6.0.0'
gem 'mocha', '~> 2.1.0'
gem 'test_declarative', '0.0.6'
gem 'rake'
gem 'minitest', '~> 5.14'
gem 'racc'

platforms :mri do
  gem 'oj'
end
