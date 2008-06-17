$:.unshift File.dirname(__FILE__)

require 'i18n/core_ext'
require 'i18n/locale'

module I18n
  extend Translation
  @@default_locale = 'en-US'
  
  class << self
    def current_locale
      Thread.current[:locale] ||= Locale[@@default_locale]
    end

    def current_locale=(locale)
      Thread.current[:locale] = locale
    end
  end
  
  @@backend = nil
  def self.backend; @@backend; end
  def self.backend=(new_val); @@backend = new_val; end
end
