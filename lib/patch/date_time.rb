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
    formats = :formats.t(locale, :scope => :time)
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

# require 'date'
# require 'time'
# 
# class Date
#   # Acts the same as #strftime, but returns a localized version of the 
#   # formatted date string.
#   def localize(locale = nil, format = :default)
#     formats = I18n.t formats, locale, :scope => :time
#     format = formats[format.to_sym] if formats[format.to_sym]      
#     format = format.dup
#     
#     format.gsub! /%a/, I18n.t(:abbr_day_names, locale, :scope => :date)[wday]
#     format.gsub! /%A/, I18n.t(:day_names, locale, :scope => :date)[wday]
#     format.gsub! /%b/, I18n.t(:abbr_month_names, locale, :scope => :date)[mon]
#     format.gsub! /%B/, I18n.t(:month_names, locale, :scope => :date)[mon]
#     format.gsub! /%p/, I18n.t((hour < 12 ? :am : :pm), locale, :scope => :time)
#     strftime(format)
#   end
#   alias :l :localize
# end
# 
# class Time
#   # Acts the same as #strftime, but returns a localized version of the
#   # formatted date/time string.
#   def localize(locale = nil, format = :default)
#     formats = locale.t formats, locale, :scope => :time
#     format = formats[format.to_sym] if formats[format.to_sym]      
#     format = format.dup
#     
#     format.gsub! /%a/, I18n.t(:abbr_day_names, locale, :scope => :date)[wday]
#     format.gsub! /%A/, I18n.t(:day_names, locale, :scope => :date)[wday]
#     format.gsub! /%b/, I18n.t(:abbr_month_names, locale, :scope => :date)[mon]
#     format.gsub! /%B/, I18n.t(:month_names, locale, :scope => :date)[mon]
#     format.gsub! /%p/, I18n.t((hour < 12 ? :am : :pm), locale, :scope => :time)
#     strftime(format)
#   end
#   alias :l :localize
# end
# 
