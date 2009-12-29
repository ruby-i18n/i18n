$:.unshift File.expand_path("../lib", File.dirname(__FILE__))

require 'i18n'
require 'i18n/core_ext/object/meta_class'
require 'benchmark'
require 'yaml'

YAML_HASH = YAML.load_file(File.expand_path("example.yml", File.dirname(__FILE__)))

def create_backend(*modules)
  Class.new do
    modules.unshift(I18n::Backend::Base)
    modules.each { |m| include m }
  end
end

BACKENDS = []
BACKENDS << (SimpleBackend = create_backend)
BACKENDS << (FastBackend   = create_backend(I18n::Backend::Fast))

BACKENDS.each do |backend|
  puts backend.name
  I18n.backend = backend.new

  print "Store translations time:  "
  puts Benchmark.realtime {
    I18n.backend.store_translations *(YAML_HASH.to_a.first)
    I18n.backend.translate :en, :first
  } * 1000

  print "Translate a key (size 3): "
  puts Benchmark.realtime {
    I18n.backend.translate :en, :"activerecord.models.user"
  } * 1000

  print "Translate a key (size 5): "
  puts Benchmark.realtime {
    I18n.backend.translate :en, :"activerecord.errors.models.user.blank"
  } * 1000

  print "Translate a key (size 7): "
  puts Benchmark.realtime {
    I18n.backend.translate :en, :"activerecord.errors.models.user.attributes.login.blank"
  } * 1000

  print "Translate with default:   "
  puts Benchmark.realtime {
    I18n.backend.translate :en, :"activerecord.models.another", :default => "Another"
  } * 1000

  print "Translate subtree:        "
  puts Benchmark.realtime {
    I18n.backend.translate :en, :"activerecord.errors.messages"
  } * 1000

  puts
end