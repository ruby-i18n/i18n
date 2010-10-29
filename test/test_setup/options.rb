require 'optparse'

module Test
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
  end
end

Test.parse_options!
