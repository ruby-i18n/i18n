require 'strscan'

module I18n
  module Backend
    module Minimal
      class << self
        def translate(options = {})
          return unless string = options[:default]
          values = options.reject{|key, value| [:keys, :locale, :default].include? key }      
          string = interpolate string, values unless values.empty?
          string
        end
    
        # Interpolates values into a given text.
        # 
        #   interpolate "file {{file}} opend by \\{{user}}", :file => 'test.txt', :user => 'Mr. X'  # => "file test.txt opend by {{user}}"
        # 
        # Note that you have to double escape the "\" when you want to escape
        # the {{...}} key in a string (once for the string and once for the
        # interpolation).
        def interpolate(text, values = {})
          s = StringScanner.new text

          while s.skip_until /\{\{/
            s.string[s.pos - 3, 1] = '' and next if s.pre_match[-1, 1] == '\\'
            start_pos = s.pos - 2
            key_name = s.scan_until(/\}\}/)[0..-3]
            end_pos = s.pos - 1
        
            if values.has_key? key_name.to_sym
              s.string[start_pos..end_pos] = values[key_name.to_sym].to_s
            end        
            s.unscan
          end      
          s.string
        end
      end
    end
  end
end      