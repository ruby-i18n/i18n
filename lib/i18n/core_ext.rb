require 'i18n/localization'
require 'i18n/translation'

class String
  include I18n::Translation
  
  protected
  
  # Prepend this symbol to the args array.
  def typify_localization_args(args)
    args.unshift self
  end
end

class Symbol
  include I18n::Translation
  
  protected
  
  # Prepend this symbol to the args array.
  def typify_localization_args(args)
    args.unshift self
  end
end

class Time
  include I18n::Localization
end

# class Date
#   include I18n::Localization
# end
# 
# class DateTime
#   include I18n::Localization
# end
