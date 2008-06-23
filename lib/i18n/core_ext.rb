require 'date'
require 'time'

class String
  # Translates the String as a translation key. 
  #
  # Can be used to look up nested translations using dot separated keys like 
  # in <tt>"currency.format.precision".t</tt> which would return 2 for the locale <tt>en-US</tt>.
  # 
  # See I18n#translate for more options.
  def translate(*args)
    I18n.translate self, *args
  end
  alias :t :translate
end

class Symbol
  # Translates the Symbol as a translation key.
  #
  # Can be used to look up nested translations using dot separated keys like 
  # in <tt>:"currency.format.precision".t</tt> which would return 2 for the locale <tt>en-US</tt>.
  # 
  # See I18n#translate for more options.
  def translate(*args)
    I18n.translate self, *args
  end
  alias :t :translate
end

class Date
  # Acts the same as #strftime, but returns a localized version of the 
  # formatted date string.
  def localize(*args)
    I18n.localize self, *args
  end
  alias :l :localize
end

class Time
  # Acts the same as #strftime, but returns a localized version of the
  # formatted time string.
  def localize(*args)
    I18n.localize self, *args
  end
  alias :l :localize
end

class DateTime
  # Acts the same as #strftime, but returns a localized version of the
  # formatted date/time string.
  def localize(*args)
    I18n.localize self, *args
  end
  alias :l :localize
end
