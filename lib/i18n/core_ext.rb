require 'i18n/localization_mixin'
require 'i18n/translation_mixin'

class String
  include I18n::TranslationMixin
  
  protected
  
  # Define the value of this string as the default value if default value is
  # given.
  def typify_localization_options(options)
    options[:default] = self unless options[:default]
    options
  end
end

class Symbol
  include I18n::TranslationMixin
  
  protected
  
  # Add this symbol to the keys array.
  def typify_localization_options(options)
    options[:keys] << self
    options
  end
end

class Time
  include I18n::LocalizationMixin
end

class Date
  include I18n::LocalizationMixin
end

class DateTime
  include I18n::LocalizationMixin
end
