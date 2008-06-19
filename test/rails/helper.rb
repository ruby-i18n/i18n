TEST_ROOT       = File.expand_path(File.dirname(__FILE__))
ASSETS_ROOT     = TEST_ROOT + "/assets"
FIXTURES_ROOT   = TEST_ROOT + "/fixtures"
MIGRATIONS_ROOT = TEST_ROOT + "/migrations"
SCHEMA_ROOT     = TEST_ROOT + "/schema"

unless File.exists?(FIXTURES_ROOT)
  require 'fileutils'
  FileUtils.mkdir(FIXTURES_ROOT) 
end


active_record_path = $:.detect{|path| path =~ %r(/activerecord.*/lib)}.sub(%r(/lib$), '')
$:.unshift active_record_path + '/test'
$:.unshift active_record_path + '/test/connections/native_sqlite3'

require 'test/unit'
require 'active_record'
require 'active_record/fixtures'
require 'active_record/test_case'

require 'connection'

ActiveRecord::Schema.define do
  create_table :topics, :force => true do |t|
    t.string   :title
    t.string   :author_name
    t.string   :author_email_address
    t.datetime :written_on
    t.time     :bonus_time
    t.date     :last_read
    t.text     :content
    t.boolean  :approved, :default => true
    t.integer  :replies_count, :default => 0
    t.integer  :parent_id
    t.string   :type
  end
end unless ActiveRecord::Base.connection.table_exists?(:topics)

require 'models/topic'
require 'models/reply'



# Show backtraces for deprecated behavior for quicker cleanup.
ActiveSupport::Deprecation.debug = true

# Quote "type" if it's a reserved word for the current connection.
QUOTED_TYPE = ActiveRecord::Base.connection.quote_column_name('type')

def current_adapter?(*types)
  types.any? do |type|
    ActiveRecord::ConnectionAdapters.const_defined?(type) &&
      ActiveRecord::Base.connection.is_a?(ActiveRecord::ConnectionAdapters.const_get(type))
  end
end

def uses_mocha(description)
  require 'rubygems'
  require 'mocha'
  yield
rescue LoadError
  $stderr.puts "Skipping #{description} tests. `gem install mocha` and try again."
end

ActiveRecord::Base.connection.class.class_eval do
  IGNORED_SQL = [/^PRAGMA/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/]

  def execute_with_counting(sql, name = nil, &block)
    $query_count ||= 0
    $query_count  += 1 unless IGNORED_SQL.any? { |r| sql =~ r }
    execute_without_counting(sql, name, &block)
  end

  alias_method_chain :execute, :counting
end

# Make with_scope public for tests
class << ActiveRecord::Base
  public :with_scope, :with_exclusive_scope
end
