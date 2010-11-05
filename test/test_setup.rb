$KCODE = 'u' if RUBY_VERSION <= '1.9'

require 'rubygems'
require 'test/unit'
require 'optparse'

# Do not load the i18n gem from libraries like active_support.
#
# This is required for testing against Rails 2.3 because active_support/vendor.rb#24 tries
# to load I18n using the gem method. Instead, we want to test the local library of course.
alias :gem_for_ruby_19 :gem # for 1.9. gives a super ugly seg fault otherwise
def gem(gem_name, *version_requirements)
  puts("skipping loading the i18n gem ...") && return if gem_name =='i18n'
  super(gem_name, *version_requirements)
end

require 'bundler/setup'
$:.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'i18n'
require 'mocha'
require 'test_declarative'

module I18n
  module Tests
    class << self
      def options
        @options ||= { :with => [], :adapter => 'sqlite3' }
      end

      def parse_options!
        OptionParser.new do |o|
          o.on('-w', '--with DEPENDENCIES', 'Define dependencies') do |dep|
            options[:with] = dep.split(',').map { |group| group.to_sym }
          end
        end.parse!

        options[:with].each do |dep|
          case dep
          when :sqlite3, :mysql, :postgres
            @options[:adapter] = dep
          when :r23, :'rails-2.3.x'
            ENV['BUNDLE_GEMFILE'] = 'ci/Gemfile.rails-2.3.x'
          when :r3, :'rails-3.0.x'
            ENV['BUNDLE_GEMFILE'] = 'ci/Gemfile.rails-3.x'
          when :'no-rails'
            ENV['BUNDLE_GEMFILE'] = 'ci/Gemfile.no-rails'
          end
        end

        ENV['BUNDLE_GEMFILE'] ||= 'ci/Gemfile.all'
      end

      def setup_rufus_tokyo
        require 'rubygems'
        require 'rufus/tokyo'
      rescue LoadError => e
        puts "can't use KeyValue backend because: #{e.message}"
      end
    end
  end
end



