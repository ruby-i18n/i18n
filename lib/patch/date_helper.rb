require 'active_support'
require 'action_view/helpers/date_helper'

module ActionView  
  module Helpers    
    module DateHelper  
      def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false, options = {})
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        distance_in_minutes = (((to_time - from_time).abs)/60).round
        distance_in_seconds = ((to_time - from_time).abs).round

        I18n.with_options :locale => options[:locale], :scope => :'datetime.distance_in_words' do |locale|
          case distance_in_minutes
            when 0..1
              return distance_in_minutes == 0 ? 
                     locale.t(:less_than_x_minutes, :count => 1) :
                     locale.t(:x_minutes, :count => distance_in_minutes) unless include_seconds

              case distance_in_seconds
                when 0..4   then locale.t :less_than_x_seconds, :count => 5
                when 5..9   then locale.t :less_than_x_seconds, :count => 10
                when 10..19 then locale.t :less_than_x_seconds, :count => 20
                when 20..39 then locale.t :half_a_minute
                when 40..59 then locale.t :less_than_x_minutes, :count => 1
                else             locale.t :x_minutes,           :count => 1
              end

            when 2..44           then locale.t :x_minutes,      :count => distance_in_minutes
            when 45..89          then locale.t :about_x_hours,  :count => 1
            when 90..1439        then locale.t :about_x_hours,  :count => (distance_in_minutes.to_f / 60.0).round
            when 1440..2879      then locale.t :x_days,         :count => 1
            when 2880..43199     then locale.t :x_days,         :count => (distance_in_minutes / 1440).round
            when 43200..86399    then locale.t :about_x_months, :count => 1
            when 86400..525599   then locale.t :x_months,       :count => (distance_in_minutes / 43200).round
            when 525600..1051199 then locale.t :about_x_years,  :count => 1
            else                      locale.t :over_x_years,   :count => (distance_in_minutes / 525600).round
          end
        end
      end
    end

    class InstanceTag
      def date_or_time_select(options, html_options = {})
        locale = options.delete :locale
        
        defaults = { :discard_type => true }
        options  = defaults.merge(options)
        datetime = value(object)
        datetime ||= default_time_from_options(options[:default]) unless options[:include_blank]

        position = { :year => 1, :month => 2, :day => 3, :hour => 4, :minute => 5, :second => 6 }

        order = options[:order] ||= :'date.order'.t(locale)

        # Discard explicit and implicit by not being included in the :order
        discard = {}
        discard[:year]   = true if options[:discard_year] or !order.include?(:year)
        discard[:month]  = true if options[:discard_month] or !order.include?(:month)
        discard[:day]    = true if options[:discard_day] or discard[:month] or !order.include?(:day)
        discard[:hour]   = true if options[:discard_hour]
        discard[:minute] = true if options[:discard_minute] or discard[:hour]
        discard[:second] = true unless options[:include_seconds] && !discard[:minute]

        # If the day is hidden and the month is visible, the day should be set to the 1st so all month choices are valid
        # (otherwise it could be 31 and february wouldn't be a valid date)
        if datetime && discard[:day] && !discard[:month]
          datetime = datetime.change(:day => 1)
        end

        # Maintain valid dates by including hidden fields for discarded elements
        [:day, :month, :year].each { |o| order.unshift(o) unless order.include?(o) }

        # Ensure proper ordering of :hour, :minute and :second
        [:hour, :minute, :second].each { |o| order.delete(o); order.push(o) }

        date_or_time_select = ''
        order.reverse.each do |param|
          # Send hidden fields for discarded elements once output has started
          # This ensures AR can reconstruct valid dates using ParseDate
          next if discard[param] && date_or_time_select.empty?

          date_or_time_select.insert(0, self.send("select_#{param}", datetime, options_with_prefix(position[param], options.merge(:use_hidden => discard[param])), html_options))
          date_or_time_select.insert(0,
            case param
              when :hour then (discard[:year] && discard[:day] ? "" : " &mdash; ")
              when :minute then " : "
              when :second then options[:include_seconds] ? " : " : ""
              else ""
            end)
        end

        date_or_time_select
      end
      
      def select_month(date, options = {}, html_options = {})
        locale = options.delete :locale

        val = date ? (date.kind_of?(Fixnum) ? date : date.month) : ''
        if options[:use_hidden]
          hidden_html(options[:field_name] || 'month', val, options)
        else
          month_options = []
          month_names = options[:use_month_names] || begin
            (options[:use_short_month] ? :'date.abbr_month_names' : :'date.month_names').t locale
          end
          month_names.unshift(nil) if month_names.size < 13

          1.upto(12) do |month_number|
            month_name = if options[:use_month_numbers]
              month_number
            elsif options[:add_month_numbers]
              month_number.to_s + ' - ' + month_names[month_number]
            else
              month_names[month_number]
            end

            month_options << ((val == month_number) ?
              content_tag(:option, month_name, :value => month_number, :selected => "selected") :
              content_tag(:option, month_name, :value => month_number)
            )
            month_options << "\n"
          end
          select_html(options[:field_name] || 'month', month_options.join, options, html_options)
        end
      end
    end
  end
end