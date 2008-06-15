require 'action_view/helpers/active_record_helper'

module ActionView  
  module Helpers    
    module ActiveRecordHelper
      def error_messages_for(*params)
        options = params.extract_options!.symbolize_keys
        if object = options.delete(:object)
          objects = [object].flatten
        else
          objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
        end
        
        locale = options.delete(:locale)
        count  = objects.inject(0) {|sum, object| sum + object.errors.count }

        unless count.zero?
          html = {}
          [:id, :class].each do |key|
            if options.include?(key)
              value = options[key]
              html[key] = value unless value.blank?
            else
              html[key] = 'errorExplanation'
            end
          end
          options[:object_name] ||= params.first

          header_message = options.include?(:header_message) ? options[:header_message] :
            :header_message.t(locale, :count => count, :object_name => options[:object_name].to_s.gsub('_', ' '), :scope => [:active_record, :error])
          message = options.include?(:message) ? options[:message] : 
            :message.t(locale, :scope => [:active_record, :error])          
          error_messages = objects.sum {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }.join

          contents = ''
          contents << content_tag(options[:header_tag] || :h2, header_message) unless header_message.blank?
          contents << content_tag(:p, message) unless message.blank?
          contents << content_tag(:ul, error_messages)

          content_tag(:div, contents, html)
        else
          ''
        end
      end      
    end
  end
end
