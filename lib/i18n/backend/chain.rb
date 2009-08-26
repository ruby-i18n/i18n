# encoding: utf-8

module I18n
  module Backend
    # Backend that chains multiple other backends and checks each of them when
    # a translation needs to be looked up. This is useful when you want to use
    # standard translations with a Simple backend but store custom application
    # translations in a database or other backends.
    #
    # To use the Chain backend instantiate it and set it to the I18n module.
    # You can add chained backends through the initializer or backends
    # accessor:
    #
    #   # preserves the existing Simple backend set to I18n.backend
    #   I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n.backend)
    #
    # The implementation assumes that all backends added to the Chain implement
    # a lookup method with the same API as Simple backend does.
    class Chain < Base
      attr_accessor :backends

      def initialize(*backends)
        self.backends = backends
      end

      def reload!
        backends.each { |backend| backend.reload! }
      end

      def store_translations(locale, data)
        backends.first.store_translations(locale, data)
      end

      def available_locales
        backends.map { |backend| backend.available_locales }.flatten.uniq
      end

      def localize(locale, object, format = :default, options = {})
        backends.each do |backend|
          begin
            result = backend.localize(locale, object, format, options) and return result
          rescue MissingTranslationData
          end
        end or nil
      end

      protected

        def lookup(locale, key, scope = [], separator = nil)
          return unless key
          result = {}
          backends.each do |backend|
            entry = backend.lookup(locale, key, scope, separator)
            if entry.is_a?(Hash)
              result.merge!(entry)
            elsif !entry.nil?
              return entry
            end
          end
          result.empty? ? nil : result
        end
    end
  end
end