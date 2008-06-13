$:.unshift File.dirname(__FILE__)

require 'i18n/core_ext'
require 'i18n/backend/minimal'

module I18n  
  @@backend = I18n::Backend::Minimal
  def self.backend; @@backend; end
  def self.backend=(new_val); @@backend = new_val; end
end