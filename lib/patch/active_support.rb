require 'activesupport'

module ActiveSupport
  module CoreExtensions
    module Array
      module Conversions
        def to_sentence(options = {})          
          options.assert_valid_keys(:connector, :skip_last_comma, :locale)
          
          locale = options[:locale]
          locale ||= request.locale if respond_to?(:request)
          
          connector = options[:connector] if options.has_key?(:connector)
          connector ||= :'support.array.sentence_connector'.t locale if :'support.array.sentence_connector'.respond_to? :t
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