require 'date'
require 'time'

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
  # formatted date/time string.
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
