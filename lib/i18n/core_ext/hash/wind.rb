class Hash
  # >> { "a" => { "b" => { "c" => "d", "e" => "f" }, "g" => "h" }, "i" => "j"}.unwind
  # => { "a.b.c" => "d", "a.b.e" => "f", "a.g" => "h", "i" => "j" }
  def unwind(separator = ".", prev_key = nil, result = {}) 
    self.inject(result) do |result, pair|
      key, value = *pair
      curr_key = [prev_key, key].compact.join(separator)
      if value.is_a?(Hash)
        value.unwind(separator, curr_key, result)
      else
        result[curr_key] = value
      end
      result
    end
  end
  
  # >> { "a.b.c" => "d", "a.b.e" => "f", "a.g" => "h", "i" => "j" }.wind
  # => { "a" => { "b" => { "c" => "d", "e" => "f" }, "g" => "h" }, "i" => "j"}
  def wind(separator = ".")
    result = {}
    self.each do |key, value|
      keys = key.split(separator)
      curr = result
      curr = curr[keys.shift] ||= {} while keys.size > 1
      curr[keys.shift] = value
    end
    result
  end
end