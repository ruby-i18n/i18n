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

      # deep_merge_hash! by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
      MERGER = proc do |key, v1, v2|
        # TODO should probably be:
        # raise TypeError.new("can't merge #{v1.inspect} and #{v2.inspect}") unless Hash === v1 && Hash === v2
        Hash === v1 && Hash === v2 ? v1.merge(v2, &MERGER) : (v2 || v1)
      end

      def deep_merge_hash!(hash, data)
        hash.merge!(data, &MERGER)
      end
    end
  end
end
