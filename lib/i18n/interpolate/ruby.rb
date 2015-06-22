# heavily based on Masao Mutoh's gettext String interpolation extension
# http://github.com/mutoh/gettext/blob/f6566738b981fe0952548c421042ad1e0cdfb31e/lib/gettext/core_ext/string.rb

module I18n
  INTERPOLATION_PATTERNS = [
    /%%/,
    /%\{(\w+)\}/,                               # matches placeholders like "%{foo}"
    /%<(\w+)>(.*?\d*\.?\d*[bBdiouxXeEfgGcps])/  # matches placeholders like "%<foo>.d"
  ]
  INTERPOLATION_PATTERN = Regexp.union(INTERPOLATION_PATTERNS)

  class << self
    # Return String or raises MissingInterpolationArgument exception.
    # Missing argument's logic is handled by I18n.config.missing_interpolation_argument_handler.
    def interpolate(string, values)
      raise ReservedInterpolationKey.new($1.to_sym, string) if string =~ RESERVED_KEYS_PATTERN
      raise ArgumentError.new('Interpolation values must be a Hash.') unless values.kind_of?(Hash)
      interpolate_hash(string, values)
    end

    def interpolate_hash(string, values)
      pattern = Regexp.union(config.interpolation_patterns)
      string.gsub(pattern) do |match_str|
        if match_str == '%%'
          '%'
        else
          placeholder, format = match_str.match(pattern).captures.reject(&:nil?)
          key = placeholder.to_sym
          value = if values.key?(key)
                    values[key]
                  else
                    config.missing_interpolation_argument_handler.call(key, values, string)
                  end
          value = value.call(values) if value.respond_to?(:call)
          format ? sprintf("%#{format}", value) : value
        end
      end
    end
  end
end
