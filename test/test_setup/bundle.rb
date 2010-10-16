# Do not load the i18n gem from libraries like active_support.
#
# This is required for testing against Rails 2.3 because active_support/vendor.rb#24 tries
# to load I18n using the gem method. Instead, we want to test the local library of course.
alias :gem_for_ruby_19 :gem # for 1.9. gives a super ugly seg fault otherwise
def gem(gem_name, *version_requirements)
  if gem_name =='i18n'
    puts "skipping loading the i18n gem ..."
    return
  end
  super(gem_name, *version_requirements)
end

require 'bundler/setup'
$:.unshift File.expand_path("../../lib", File.dirname(__FILE__))
require 'i18n'

