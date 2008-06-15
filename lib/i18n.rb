$:.unshift File.dirname(__FILE__)

require 'i18n/core_ext'
require 'locale'

module I18n
  extend Translation
  
  @@backend = nil
  def self.backend; @@backend; end
  def self.backend=(new_val); @@backend = new_val; end
end
