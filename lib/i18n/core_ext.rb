class String
  def translate(*args)
    I18n.translate self, *args
  end
  alias :t :translate
end

class Symbol
  def translate(*args)
    I18n.translate self, *args
  end
  alias :t :translate
end

# class Time
#   include I18n::Localization
# end
# 
# class Date
#   include I18n::Localization
# end
# 
# class DateTime
#   include I18n::Localization
# end
