require 'i18n/localization_mixin'
require 'i18n/translation_mixin'

class Symbol
  include I18n::TranslationMixin
  
  protected
  
  # Prepend this symbol to the args array.
  def typify_localization_args(args)
    args.unshift self
  end
end

class Time
  include I18n::LocalizationMixin
end

# class Date
#   include I18n::LocalizationMixin
# end
# 
# class DateTime
#   include I18n::LocalizationMixin
# end
