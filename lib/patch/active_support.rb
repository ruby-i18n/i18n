require 'activesupport'

module ActiveSupport
  module CoreExtensions
    module Array
      module Conversions        
        def to_sentence(options = {})          
          options.assert_valid_keys(:connector, :skip_last_comma, :locale)
          
          locale = options[:locale]
          locale ||= request.locale if respond_to?(:request)
          
          default = :'support.array.sentence_connector'.t(locale)
          options.reverse_merge! :connector => default, :skip_last_comma => false
          options[:connector] = "#{options[:connector]} " unless options[:connector].nil? || options[:connector].strip == ''

          case length
            when 0
              ""
            when 1
              self[0].to_s
            when 2
              "#{self[0]} #{options[:connector]}#{self[1]}"
            else
              "#{self[0...-1].join(', ')}#{options[:skip_last_comma] ? '' : ','} #{options[:connector]}#{self[-1]}"
          end
        end
      end
    end
  end
end