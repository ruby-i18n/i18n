class String
  if Object.const_defined?(:Encoding)
    def self.force_utf8(obj)
      obj.to_s.dup.force_encoding('UTF-8')
    end
  else
    require 'iconv'
    
    def self.force_utf8(obj)
      ::Iconv.conv('UTF-8//IGNORE', 'UTF-8', obj.to_s.dup)
    end
  end
end