require 'active_record/validations'

module ActiveRecord
  class Errors
    def full_messages(options = {})
      full_messages = []
    
      @errors.each_key do |attr|
        @errors[attr].each do |msg|
          next if msg.nil?
    
          if attr == "base"
            full_messages << msg
          else
            # TODO what would make sense here as a scope?
            scope = [:models, @base.class.name.to_sym, :human_attribute_names] 
            default = @base.class.human_attribute_name(attr)
            attr_name = I18n.t attr.to_sym, options[:locale], :scope => scope, :default => default
            full_messages << attr_name + " " + msg
          end
        end
      end
      full_messages
    end    
  end
end