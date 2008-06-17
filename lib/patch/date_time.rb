require 'date'
require 'time'

class Date
  # Acts the same as #strftime, but returns a localized version of the 
  # formatted date string.
  def localize(locale = nil, format = :default)
    formats = :formats.t(locale, :scope => :date)
    format = formats[format.to_sym] if formats[format.to_sym]      
    format = format.dup
    
    format.gsub! /%a/, :abbr_day_names.t(locale, :scope => :date)[wday]
    format.gsub! /%A/, :day_names.t(locale, :scope => :date)[wday]
    format.gsub! /%b/, :abbr_month_names.t(locale, :scope => :date)[mon]
    format.gsub! /%B/, :month_names.t(locale, :scope => :date)[mon]
    format.gsub! /%p/, (hour < 12 ? :am : :pm).t(locale, :scope => :time)
    strftime(format)
  end
  alias :l :localize
end

class Time
  # Acts the same as #strftime, but returns a localized version of the
  # formatted date/time string.
  def localize(locale = nil, format = :default)
    formats = :'time.formats'.t locale
    format = formats[format.to_sym] if formats[format.to_sym]      
    format = format.dup
    
    format.gsub! /%a/, :abbr_day_names.t(locale, :scope => :date)[wday]
    format.gsub! /%A/, :day_names.t(locale, :scope => :date)[wday]
    format.gsub! /%b/, :abbr_month_names.t(locale, :scope => :date)[mon]
    format.gsub! /%B/, :month_names.t(locale, :scope => :date)[mon]
    format.gsub! /%p/, (hour < 12 ? :am : :pm).t(locale, :scope => :time)
    strftime(format)
  end
  alias :l :localize
end
