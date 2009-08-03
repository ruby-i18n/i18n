class Hash

  # >> {"a"=>{"b"=>{"c"=>"foo", "d"=>"bar"}, "c"=>"j"}, "q"=>"asd"}.unwind
  # => {"a.c"=>"j", "a.b.d"=>"bar", "q"=>"asd", "a.b.c"=>"foo"}
  def unwind(separator = ".", key = nil, start = {}) 
    self.inject(start){|hash,k|
      expanded_key = [key, k[0]].compact.join( separator )
      if k[1].is_a? Hash
        k[1].unwind(separator, expanded_key, hash)
      else
        hash[ expanded_key ] = k[1]
      end
      hash
    }
  end
  
  # >> {"a.b.c" => "foo", "a.b.d" => "bar", "a.c" => "j", "q" => "asd"}.wind
  # => {"a"=>{"b"=>{"c"=>"foo", "d"=>"bar"}, "c"=>"j"}, "q"=>"asd"}
  def wind(separator = ".", key = nil, start = {})
    wound = Hash.new
    self.each {|key, value|
      keys = key.split( separator )
      index = 0
      keys.inject(wound){|h,v|
        index += 1
        if index >= keys.size
          h[v.to_sym] = value
          break
        else
          h[v.to_sym] ||= {}
        end
      }
    }
    wound
  end
  
end