require 'active_record'

module I18n
  module Backend
    class ActiveRecord < Base
      class Translation < ::ActiveRecord::Base
        set_table_name 'translations'
        attr_protected :is_proc
        serialize :value

        named_scope :locale, lambda {|locale|
          { :conditions => {:locale => locale } }
        }

        named_scope :key, lambda { |key|
          { :conditions => {:key => key} }
        }

        named_scope :keys, lambda { |key, separator|
          separator ||= I18n.default_separator
          { :conditions => "`key` LIKE '#{key}#{separator}%'" }
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