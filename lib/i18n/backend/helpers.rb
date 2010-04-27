module I18n
  module Backend
    module Helpers
      SEPARATOR_ESCAPE_CHAR = "\001"
      WIND_SEPARATOR = "."

      # Return a new hash with all keys and nested keys converted to symbols.
      def deep_symbolize_keys(hash)
        hash.inject({}) { |result, (key, value)|
          value = deep_symbolize_keys(value) if value.is_a?(Hash)
          result[(key.to_sym rescue key) || key] = value
          result
        }
      end

      # Flatten keys for nested Hashes by chaining up keys using the separator
      #   >> { "a" => { "b" => { "c" => "d", "e" => "f" }, "g" => "h" }, "i" => "j"}.wind
      #   => { "a.b.c" => "d", "a.b.e" => "f", "a.g" => "h", "i" => "j" }
      def wind_keys(hash, subtree = false, prev_key = nil, result = {}, orig_hash=hash)
        hash.each_pair do |key, value|
          key = escape_default_separator(key)
          curr_key = [prev_key, key].compact.join(WIND_SEPARATOR).to_sym

          if value.is_a?(Hash)
            result[curr_key] = value if subtree
            wind_keys(value, subtree, curr_key, result, orig_hash)
          else
            result[curr_key] = value
          end
        end

        result
      end

      def escape_default_separator(key)
        key.to_s.tr(WIND_SEPARATOR, SEPARATOR_ESCAPE_CHAR)
      end
    end
  end
end
