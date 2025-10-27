# frozen_string_literal: true

module I18n
  module Backend
    module Deprecator
      def store_translations(locale, data, options = EMPTY_HASH)
        super

        I18n.config.deprecations.each do |deprecated_key, new_key|
          if lookup(locale, deprecated_key)
            puts "DEPRECATION WARNING: #{deprecated_key} is deprecated, use #{new_key} instead"
          end
        end
      end
    end
  end
end
