#! /usr/bin/ruby
$:.unshift File.expand_path("../lib", File.dirname(__FILE__))

require 'i18n'
require 'benchmark'
require 'yaml'

N = (ARGV.shift || 1000).to_i
YAML_HASH = YAML.load_file(File.expand_path("example.yml", File.dirname(__FILE__)))

module Backends
  Simple = I18n::Backend::Simple.new

  Fast = Class.new do
    include I18n::Backend::Base
    include I18n::Backend::Fast
  end.new

  Interpolation = Class.new do
    include I18n::Backend::Base
    include I18n::Backend::InterpolationCompiler
  end.new

  FastInterpolation = Class.new do
    include I18n::Backend::Base
    include I18n::Backend::Fast
    include I18n::Backend::InterpolationCompiler
  end.new
end

module Benchmark
  WIDTH = 20

  def self.rt(label = "", n=N, &blk)
    print label.ljust(WIDTH)
    time, objects = measure_objects(n, &blk)
    time = time.respond_to?(:real) ? time.real : time
    print format("%8.2f ms  %8d objects\n", time * 1000, objects)
  end

  if ObjectSpace.respond_to?(:allocated_objects)
    def self.measure_objects(n, &blk)
      obj = ObjectSpace.allocated_objects
      t = Benchmark.realtime { n.times(&blk) }
      [t, ObjectSpace.allocated_objects - obj]
    end
  else
    def self.measure_objects(n, &blk)
      [Benchmark.measure { n.times(&blk) }, 0]
    end
  end
end

# Run!
puts "Running benchmarks with N = #{N}\n\n"

Backends.constants.each do |backend_name|
  I18n.backend = Backends.const_get(backend_name)
  puts "===> #{backend_name}\n\n"

  Benchmark.rt "store", 1 do
    I18n.backend.store_translations *(YAML_HASH.to_a.first)
    I18n.backend.translate :en, :first
  end

  Benchmark.rt "t (depth=3)" do
    I18n.backend.translate :en, :"activerecord.models.user"
  end

  Benchmark.rt "t (depth=5)" do
    I18n.backend.translate :en, :"activerecord.attributes.admins.user.login"
  end

  Benchmark.rt "t (depth=7)" do
    I18n.backend.translate :en, :"activerecord.errors.models.user.attributes.login.blank"
  end

  Benchmark.rt "t w/ default" do
    I18n.backend.translate :en, :"activerecord.models.another", :default => "Another"
  end

  Benchmark.rt "t w/ interpolation" do
    I18n.backend.translate :en, :"activerecord.errors.models.user.blank", :model => "User", :attribute => "name"
  end

  Benchmark.rt "t w/ link" do
    I18n.backend.translate :en, :"activemodel.errors.messages.blank"
  end

  Benchmark.rt "t subtree" do
    I18n.backend.translate :en, :"activerecord.errors.messages"
  end

  puts
end
