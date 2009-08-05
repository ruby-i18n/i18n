require 'active_record'

module I18n
  module Backend
    class ActiveRecord < Base
      class Translation < ::ActiveRecord::Base
        set_table_name 'translations'
        attr_protected :is_proc
        serialize :value

        named_scope :locale, lambda { |locale|
          { :conditions => { :locale => locale.to_s } }
        }

        named_scope :lookup, lambda { |keys, separator|
          keys = Array(keys).map! { |key| key.to_s }
          separator ||= I18n.default_separator
          { :conditions => ["`key` IN (?) OR `key` LIKE '#{keys.last}#{separator}%'", keys] }
        }

        def value
          if is_proc
            Kernel.eval read_attribute(:value)
          else
            read_attribute(:value)
          end
        end
      end
    end
  end
end
