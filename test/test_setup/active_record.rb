module Test
  class << self
    def setup_active_record
      begin
        require 'active_record'
        ActiveRecord::Base.connection
        true
      rescue LoadError => e
        puts "can't use ActiveRecord backend because: #{e.message}"
      rescue ActiveRecord::ConnectionNotEstablished
        require 'i18n/backend/active_record'
        require 'i18n/backend/active_record/store_procs'
        connect_active_record
        true
      end
    end

    def connect_active_record
      connect_adapter
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Schema.define(:version => 1) do
        create_table :translations, :force => true do |t|
          t.string :locale
          t.string :key
          t.text :value
          t.text :interpolations
          t.boolean :is_proc, :default => false
        end
        add_index :translations, [:locale, :key], :unique => true
      end
    end

    def connect_adapter
      case options[:adapter].to_sym
      when :sqlite3
        ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
      when :mysql
        # CREATE DATABASE i18n_unittest;
        # CREATE USER 'i18n'@'localhost' IDENTIFIED BY '';
        # GRANT ALL PRIVILEGES ON i18n_unittest.* to 'i18n'@'localhost';
        ActiveRecord::Base.establish_connection(:adapter => "mysql", :database => "i18n_unittest", :username => "i18n", :password => "", :host => "localhost")
      end
    end
  end
end

