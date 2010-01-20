# encoding: utf-8

$:.unshift File.expand_path("../lib", File.dirname(__FILE__))
$:.unshift File.expand_path(File.dirname(__FILE__))

require 'i18n'
require 'i18n/core_ext/object/meta_class'

require 'rubygems'
require 'test/unit'
require 'time'
require 'yaml'

# Overwrite *gem* to not load i18n gem by libraries like active_support
def gem(gem_name, *version_requirements)
  if gem_name =='i18n'
    puts "Skiping loading i18n gem..."
    return
  end
  super(gem_name, *version_requirements)
end

begin
  require 'mocha'
rescue LoadError
  puts "skipping tests using mocha as mocha can't be found"
end


Dir[File.dirname(__FILE__) + '/api/**/*.rb'].each do |filename|
  require filename
end

$KCODE = 'u' unless RUBY_VERSION >= '1.9'

# wtf is wrong with this, why's there Kernel#test?
# class Module
#   def self.test(name, &block)
#     define_method("test: " + name, &block)
#   end
# end

class Test::Unit::TestCase
  def self.test(name, &block)
    test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end

  def self.with_mocha
    yield if Object.respond_to?(:expects)
  end

  def teardown
    I18n.locale = nil
    I18n.default_locale = :en
    I18n.load_path = []
    I18n.available_locales = nil
    I18n.backend = nil
  end

  def translations
    I18n.backend.instance_variable_get(:@translations)
  end

  def store_translations(*args)
    data   = args.pop
    locale = args.pop || :en
    I18n.backend.store_translations(locale, data)
  end

  def locales_dir
    File.dirname(__FILE__) + '/locales'
  end

  def euc_jp(string)
    string.encode!(Encoding::EUC_JP)
  end

  def can_store_procs?
    I18n::Backend::ActiveRecord === I18n.backend and
    I18n::Backend::ActiveRecord.included_modules.include?(I18n::Backend::ActiveRecord::StoreProcs)
  end
end

def setup_active_record
  begin
    require 'activerecord'
    require 'i18n/backend/active_record'
    require 'i18n/backend/active_record/store_procs'

    if I18n::Backend::Simple.method_defined?(:interpolate_with_deprecated_syntax)
      I18n::Backend::Simple.send(:remove_method, :interpolate) rescue NameError
    end

    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define(:version => 1) do
      create_table :translations do |t|
        t.string :locale
        t.string :key
        t.string :value
        t.string :interpolations
        t.boolean :is_proc, :default => false
      end
    end

  rescue LoadError
    puts "skipping tests using activerecord as activerecord can't be found"
  end
end
