require 'active_record/validations'

module ActiveRecord
  class Errors
    def add(attribute, msg = nil)
      msg ||= :"active_record.error_messages.invalid".t
      @errors[attribute.to_s] = [] if @errors[attribute.to_s].nil?
      @errors[attribute.to_s] << msg
    end

    # Will add an error message to each of the attributes in +attributes+ that is empty.
    def add_on_empty(attributes, custom_message = nil)
      for attr in [attributes].flatten
        value = @base.respond_to?(attr.to_s) ? @base.send(attr.to_s) : @base[attr.to_s]
        is_empty = value.respond_to?("empty?") ? value.empty? : false
        unless !value.nil? && !is_empty
          custom_key = :"active_record.error_messages.custom.#{self.class.name}.#{attr}.empty"
          message = custom_key.t :default => custom_message
          message ||= :"active_record.error_messages.empty".t        
          add(attr, message) 
        end
      end
    end

    # Will add an error message to each of the attributes in +attributes+ that is blank (using Object#blank?).
    def add_on_blank(attributes, custom_message = nil)
      for attr in [attributes].flatten
        value = @base.respond_to?(attr.to_s) ? @base.send(attr.to_s) : @base[attr.to_s]
        if value.blank?
          custom_key = :"active_record.error_messages.custom.#{self.class.name}.#{attr}.blank"
          message = custom_key.t :default => custom_message
          message ||= :"active_record.error_messages.blank".t
          add(attr, message) 
        end
      end
    end
    
    def full_messages(options = {})
      full_messages = []
    
      @errors.each_key do |attr|
        @errors[attr].each do |msg|
          next if msg.nil?
    
          if attr == "base"
            full_messages << msg
          else
            # TODO what would make sense here as a scope?
            key = :"models#{@base.class.name.to_sym}.human_attribute_names.#{attr}" 
            default = @base.class.human_attribute_name(attr)
            attr_name = key.t options[:locale], :default => default
            full_messages << attr_name + " " + msg
          end
        end
      end
      full_messages
    end 
  end
  
  module Validations    
    module ClassMethods
      def validates_confirmation_of(*attr_names)
        configuration = { :on => :save }
        configuration.update(attr_names.extract_options!)

        attr_accessor(*(attr_names.map { |n| "#{n}_confirmation" }))

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless record.send("#{attr_name}_confirmation").nil? or value == record.send("#{attr_name}_confirmation")
            custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr_name}.confirmation"
            message = custom_key.t :default => configuration[:message]
            message ||= :"active_record.error_messages.confirmation".t
            record.errors.add(attr_name, message) 
          end
        end
      end 
    
      def validates_acceptance_of(*attr_names)
        configuration = { :on => :save, :allow_nil => true, :accept => "1" }
        configuration.update(attr_names.extract_options!)

        db_cols = begin
          column_names
        rescue ActiveRecord::StatementInvalid
          []
        end
        names = attr_names.reject { |name| db_cols.include?(name.to_s) }
        attr_accessor(*names)

        validates_each(attr_names,configuration) do |record, attr_name, value|
          unless value == configuration[:accept]
            custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr_name}.accepted"
            message = custom_key.t :default => configuration[:message]
            message ||= :"active_record.error_messages.accepted".t
            record.errors.add(attr_name, message) 
          end
        end
      end
      
      def validates_presence_of(*attr_names)
        configuration = { :on => :save }
        configuration.update(attr_names.extract_options!)

        # can't use validates_each here, because it cannot cope with nonexistent attributes,
        # while errors.add_on_empty can
        send(validation_method(configuration[:on]), configuration) do |record|
          record.errors.add_on_blank(attr_names, configuration[:message])
        end
      end
      
      def validates_length_of(*attrs)
        # Merge given options with defaults.
        options = {}.merge(DEFAULT_VALIDATION_OPTIONS)
        options.update(attrs.extract_options!.symbolize_keys)

        # Ensure that one and only one range option is specified.
        range_options = ALL_RANGE_OPTIONS & options.keys
        case range_options.size
          when 0
            raise ArgumentError, 'Range unspecified.  Specify the :within, :maximum, :minimum, or :is option.'
          when 1
            # Valid number of options; do nothing.
          else
            raise ArgumentError, 'Too many range options specified.  Choose only one.'
        end

        # Get range option and value.
        option = range_options.first
        option_value = options[range_options.first]

        case option
          when :within, :in
            raise ArgumentError, ":#{option} must be a Range" unless option_value.is_a?(Range)

            validates_each(attrs, options) do |record, attr, value|
              custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr}.too_short"
              too_short = custom_key.t :default => options[:too_short], :count => option_value.begin
              too_short ||= :"active_record.error_messages.too_short".t :count => option_value.begin

              custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr}.too_long"
              too_long = custom_key.t :default => options[:too_long], :count => option_value.end
              too_long ||= :"active_record.error_messages.too_long".t :count => option_value.end

              value = value.split(//) if value.kind_of?(String)
              if value.nil? or value.size < option_value.begin
                record.errors.add(attr, too_short)
              elsif value.size > option_value.end
                record.errors.add(attr, too_long)
              end
            end
          when :is, :minimum, :maximum
            raise ArgumentError, ":#{option} must be a nonnegative Integer" unless option_value.is_a?(Integer) and option_value >= 0

            # Declare different validations per option.
            validity_checks = { :is => "==", :minimum => ">=", :maximum => "<=" }
            message_options = { :is => :wrong_length, :minimum => :too_short, :maximum => :too_long }

            validates_each(attrs, options) do |record, attr, value|
              custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr}.#{message_options[option]}"
              custom_message = options[:message] || options[message_options[option]]
              message = custom_key.t :default => custom_message, :count => option_value
              message ||= :"active_record.error_messages.#{message_options[option]}".t :count => option_value
            
              value = value.split(//) if value.kind_of?(String)
              record.errors.add(attr, message) unless !value.nil? and value.size.method(validity_checks[option])[option_value]
            end
        end
      end
      
      def validates_uniqueness_of(*attr_names)
        configuration = { :case_sensitive => true }
        configuration.update(attr_names.extract_options!)

        validates_each(attr_names,configuration) do |record, attr_name, value|
          # The check for an existing value should be run from a class that
          # isn't abstract. This means working down from the current class
          # (self), to the first non-abstract class. Since classes don't know
          # their subclasses, we have to build the hierarchy between self and
          # the record's class.
          class_hierarchy = [record.class]
          while class_hierarchy.first != self
            class_hierarchy.insert(0, class_hierarchy.first.superclass)
          end

          # Now we can work our way down the tree to the first non-abstract
          # class (which has a database table to query from).
          finder_class = class_hierarchy.detect { |klass| !klass.abstract_class? }

          if value.nil? || (configuration[:case_sensitive] || !finder_class.columns_hash[attr_name.to_s].text?)
            condition_sql = "#{record.class.quoted_table_name}.#{attr_name} #{attribute_condition(value)}"
            condition_params = [value]
          else
            # sqlite has case sensitive SELECT query, while MySQL/Postgresql don't.
            # Hence, this is needed only for sqlite.
            condition_sql = "LOWER(#{record.class.quoted_table_name}.#{attr_name}) #{attribute_condition(value)}"
            condition_params = [value.downcase]
          end

          if scope = configuration[:scope]
            Array(scope).map do |scope_item|
              scope_value = record.send(scope_item)
              condition_sql << " AND #{record.class.quoted_table_name}.#{scope_item} #{attribute_condition(scope_value)}"
              condition_params << scope_value
            end
          end

          unless record.new_record?
            condition_sql << " AND #{record.class.quoted_table_name}.#{record.class.primary_key} <> ?"
            condition_params << record.send(:id)
          end

          results = finder_class.with_exclusive_scope do
            connection.select_all(
              construct_finder_sql(
                :select     => "#{connection.quote_column_name(attr_name)}",
                :from       => "#{finder_class.quoted_table_name}",
                :conditions => [condition_sql, *condition_params]
              )
            )
          end

          unless results.length.zero?
            found = true

            # As MySQL/Postgres don't have case sensitive SELECT queries, we try to find duplicate
            # column in ruby when case sensitive option
            if configuration[:case_sensitive] && finder_class.columns_hash[attr_name.to_s].text?
              found = results.any? { |a| a[attr_name.to_s] == value }
            end
            
            custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr_name}.taken"
            message = custom_key.t :default => configuration[:message]
            message ||= :"active_record.error_messages.taken".t            
            record.errors.add(attr_name, message) if found
          end
        end
      end
      
      def validates_format_of(*attr_names)
        configuration = { :on => :save, :with => nil }
        configuration.update(attr_names.extract_options!)

        raise(ArgumentError, "A regular expression must be supplied as the :with option of the configuration hash") unless configuration[:with].is_a?(Regexp)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless value.to_s =~ configuration[:with]
            custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr_name}.invalid"
            message = custom_key.t :default => configuration[:message], :value => value
            message ||= :"active_record.error_messages.invalid".t :value => value
            record.errors.add(attr_name, message) 
          end
        end
      end
      
      def validates_inclusion_of(*attr_names)
        configuration = { :on => :save, :with => nil }
        configuration.update(attr_names.extract_options!)

        enum = configuration[:in] || configuration[:within]

        raise(ArgumentError, "An object with the method include? is required must be supplied as the :in option of the configuration hash") unless enum.respond_to?("include?")

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless enum.include?(value)
            custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr_name}.inclusion"
            message = custom_key.t :default => configuration[:message], :value => value
            message ||= :"active_record.error_messages.inclusion".t :value => value
            record.errors.add(attr_name, message) 
          end
        end
      end
      
      def validates_exclusion_of(*attr_names)
        configuration = { :on => :save, :with => nil }
        configuration.update(attr_names.extract_options!)

        enum = configuration[:in] || configuration[:within]

        raise(ArgumentError, "An object with the method include? is required must be supplied as the :in option of the configuration hash") unless enum.respond_to?("include?")

        validates_each(attr_names, configuration) do |record, attr_name, value|
          if enum.include?(value)
            custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr_name}.exclusion"
            message = custom_key.t :default => configuration[:message], :value => value
            message ||= :"active_record.error_messages.exclusion".t :value => value
            record.errors.add(attr_name, message) 
          end
        end
      end
      
      def validates_associated(*attr_names)
        configuration = { :on => :save }
        configuration.update(attr_names.extract_options!)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless (value.is_a?(Array) ? value : [value]).inject(true) { |v, r| (r.nil? || r.valid?) && v }
            custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr_name}.invalid"
            message = custom_key.t :default => configuration[:message]
            message ||= :"active_record.error_messages.invalid".t
            record.errors.add(attr_name, message)
          end
        end
      end
      
      def validates_numericality_of(*attr_names)
        configuration = { :on => :save, :only_integer => false, :allow_nil => false }
        configuration.update(attr_names.extract_options!)


        numericality_options = ALL_NUMERICALITY_CHECKS.keys & configuration.keys

        (numericality_options - [ :odd, :even ]).each do |option|
          raise ArgumentError, ":#{option} must be a number" unless configuration[option].is_a?(Numeric)
        end

        validates_each(attr_names,configuration) do |record, attr_name, value|
          raw_value = record.send("#{attr_name}_before_type_cast") || value

          next if configuration[:allow_nil] and raw_value.nil?

          if configuration[:only_integer]
            unless raw_value.to_s =~ /\A[+-]?\d+\Z/
              custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr_name}.not_a_number"
              message = custom_key.t :default => configuration[:message]
              message ||= :"active_record.error_messages.not_a_number".t
              record.errors.add(attr_name, message)
              next
            end
            raw_value = raw_value.to_i
          else
           begin
              raw_value = Kernel.Float(raw_value.to_s)
            rescue ArgumentError, TypeError
              custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr_name}.not_a_number"
              message = custom_key.t :default => configuration[:message]
              message ||= :"active_record.error_messages.not_a_number".t
              record.errors.add(attr_name, message)
              next
            end
          end

          numericality_options.each do |option|
            case option
              when :odd, :even
                unless raw_value.to_i.method(ALL_NUMERICALITY_CHECKS[option])[]
                  custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr_name}.#{option}"
                  message = custom_key.t :default => configuration[:message]
                  message ||= :"active_record.error_messages.#{option}".t
                  record.errors.add(attr_name, message) 
                end
              else
                custom_key = :"active_record.error_messages.custom.#{record.class.name}.#{attr_name}.#{option}"
                message = custom_key.t :default => configuration[:message], :count => configuration[option] if configuration[:message]
                message ||= :"active_record.error_messages.#{option}".t :count => configuration[option]
                record.errors.add(attr_name, message) unless raw_value.method(ALL_NUMERICALITY_CHECKS[option])[configuration[option]]
            end
          end
        end
      end
    end
  end
end