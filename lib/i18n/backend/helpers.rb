module I18n
  module Backend
    module Helpers
      # Return a new hash with all keys and nested keys converted to symbols.
      def deep_symbolize_keys(hash)
        hash.inject({}) { |result, (key, value)|
          value = deep_symbolize_keys(value) if value.is_a?(Hash)
          result[(key.to_sym rescue key) || key] = value
          result
        }
      end
    end
  end
end
