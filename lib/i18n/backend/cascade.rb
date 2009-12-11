# encoding: utf-8

module I18n
  @@fallbacks = nil

  module Backend
    module Cascade
      def lookup(locale, key, scope = [], separator = nil)
        return unless key
        locale, *scope = I18n.send(:normalize_translation_keys, locale, key, scope, separator)
        key = scope.pop

        begin
          result = super
          return result unless result.nil?
        end while scope.pop
      end
    end
  end
end
