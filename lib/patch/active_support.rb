require 'activesupport'

module ActiveSupport
  module CoreExtensions
    module Array
      module Conversions
        def to_sentence(options = {})          
          options.assert_valid_keys(:connector, :skip_last_comma)

          connector = options.has_key?(:connector) ? options[:connector] : 
            :array_sentence_connector.t(options[:locale], :scope => :support)
          connector = "#{connector} " unless connector.nil? || connector.strip == ''

          case length
            when 0
              ""
            when 1
              self[0].to_s
            when 2
              "#{self[0]} #{connector}#{self[1]}"
            else
              "#{self[0...-1].join(', ')}#{options[:skip_last_comma] ? '' : ','} #{connector}#{self[-1]}"
          end
        end
      end
    end
  end
end