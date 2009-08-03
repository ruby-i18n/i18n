require 'active_record'
require 'ruby2ruby'
require 'parse_tree'
require 'parse_tree_extensions'

class Translation < ActiveRecord::Base
  
  attr_protected :proc
  serialize :value
  
  named_scope :locale, lambda {|locale|
    { :conditions => {:locale => locale }}
  }
  
  named_scope :key, lambda { |key|
    { :conditions => {:key => key} }
  }
  
  named_scope :keys, lambda { |key, separator|
    separator ||= I18n.default_separator
    { :conditions => "key LIKE '#{key}#{separator}%'" }
  }
  
  def value=(v)
    case v
      when Proc
        write_attribute(:value, v.to_ruby)
        write_attribute(:proc, true)
      else
        write_attribute(:value, v)
    end
  end
  
  def value
    if proc
      Kernel.eval read_attribute( :value )
    else
      read_attribute( :value )
    end
  end
  
end