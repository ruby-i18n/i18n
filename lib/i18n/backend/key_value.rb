# encoding: utf-8
require 'i18n/backend/base'
require 'active_support/json'

module I18n
  module Backend
    # This is a basic backend for key value stores. It receives on
    # initialization the store, which should respond to three methods:
    #
    # * store#[](key)         - Used to get a value
    # * store#[]=(key, value) - Used to set a value
    # * store#keys            - Used to get all keys
    #
    # Since these stores only supports string, all values are converted
    # to JSON before being stored, allowing it to also store booleans,
    # hashes and arrays. However, this store does not support Procs.
    #
    # As the ActiveRecord backend, Symbols are just supported when loading
    # translations from the filesystem or through explicit store translations.
    #
    # Also, avoid calling I18n.available_locales since it's a somehow
    # expensive operation in most stores.
    #
    # == Example
    #
    # To setup I18n to use TokyoCabinet in memory is quite straightforward:
    #
    #   require 'rufus/tokyo/cabinet' # gem install rufus-tokyo
    #   I18n.backend = I18n::Backend::KeyValue.new(Rufus::Tokyo::Cabinet.new('*'))
    #
    class KeyValue
      attr_accessor :store

      include Base, Flatten

      def initialize(store)
        @store = store
      end

      # Mute reload! since we really don't want to clean the database.
      def reload!
      end

      def available_locales
        locales = @store.keys.map { |k| k =~ /\./; $` }
        locales.uniq!
        locales.compact!
        locales.map! { |k| k.to_sym }
        locales
      end

      protected

        def lookup(locale, key, scope = [], options = {})
          key   = normalize_keys(locale, key, scope, options[:separator])
          value = @store["#{locale}.#{key}"]
          value = ActiveSupport::JSON.decode(value) if value
          value.is_a?(Hash) ? deep_symbolize_keys(value) : value
        end

        def merge_translations(locale, data, options = {})
          flatten_translations(locale, data, true).each do |key, value|
            key = "#{locale}.#{key}"

            case value
            when Hash
              old_value = @store[key]
              if old_value
                old_value = ActiveSupport::JSON.decode(old_value) 
                value = old_value.merge(value) if old_value.is_a?(Hash)
              end
            when Proc
              raise "Key-value stores cannot handle procs"
            when Symbol
              value = nil
            end

            @store[key] = ActiveSupport::JSON.encode(value) unless value.nil?
          end
        end
    end
  end
end