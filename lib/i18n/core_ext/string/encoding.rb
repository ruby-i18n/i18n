# Makes String#force_encoding working with ruby 1.8.7
unless defined?(Encoding)
  require 'iconv'
  
  class String
    def force_encoding(encoding)
      ::Iconv.conv('UTF-8//IGNORE', encoding.upcase, self)
    end
  end
end