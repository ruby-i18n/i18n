require 'active_record/validations'

module ActiveRecord
  class Errors
    def add(attribute, message = nil)
      message ||= :"active_record.error_messages.invalid".t
      @errors[attribute.to_s] ||= []
      @errors[attribute.to_s] << message
    end

    # Will add an error message to each of the attributes in +attributes+ that is empty.
    def add_on_empty(attributes, custom_message = nil)
      for attr in [attributes].flatten
        value = @base.respond_to?(attr.to_s) ? @base.send(attr.to_s) : @base[attr.to_s]
        is_empty = value.respond_to?("empty?") ? value.empty? : false        
        add(attr, generate_message(attr, :empty, :default => custom_message)) unless !value.nil? && !is_empty
      end
    end

    # Will add an error message to each of the attributes in +attributes+ that is blank (using Object#blank?).
    def add_on_blank(attributes, custom_message = nil)
      for attr in [attributes].flatten
        value = @base.respond_to?(attr.to_s) ? @base.send(attr.to_s) : @base[attr.to_s]
        add(attr, generate_message(attr, :blank, :default => custom_message)) if value.blank?
      end
    end
    
    def generate_message(attr, key, options = {})
      scope = [:active_record, :error_messages]
      key.t(options.merge(:scope => scope + [:custom, @base.class.name.downcase, attr])) || 
      key.t(options.merge(:scope => scope))
    end
    
    def full_messages(options = {})
      full_messages = []
      locale = options[:locale]

      @errors.each_key do |attr|
        @errors[attr].each do |message|
          next unless message
    
          if attr == "base"
            full_messages << message
          else
            key = :"active_record.human_attribute_names.#{@base.class.name.underscore.to_sym}.#{attr}" 
            attr_name = key.t(locale) || @base.class.human_attribute_name(attr)
            full_messages << attr_name + " " + message
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
            message = record.errors.generate_message(attr_name, :confirmation, :default => configuration[:message])
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
            message = record.errors.generate_message(attr_name, :accepted, :default => configuration[:message])
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
              value = value.split(//) if value.kind_of?(String)
              if value.nil? or value.size < option_value.begin
                message = record.errors.generate_message(attr, :too_short, :default => options[:too_short], :count => option_value.begin)                
                record.errors.add(attr, message)
              elsif value.size > option_value.end
                message = record.errors.generate_message(attr, :too_long, :default => options[:too_long], :count => option_value.end)
                record.errors.add(attr, message)
              end
            end
          when :is, :minimum, :maximum
            raise ArgumentError, ":#{option} must be a nonnegative Integer" unless option_value.is_a?(Integer) and option_value >= 0

            # Declare different validations per option.
            validity_checks = { :is => "==", :minimum => ">=", :maximum => "<=" }
            message_options = { :is => :wrong_length, :minimum => :too_short, :maximum => :too_long }

            validates_each(attrs, options) do |record, attr, value|
              value = value.split(//) if value.kind_of?(String)
              unless !value.nil? and value.size.method(validity_checks[option])[option_value]
                key = message_options[option]
                custom_message = options[:message] || options[key]
                message = record.errors.generate_message(attr, key, :default => custom_message, :count => option_value)
                record.errors.add(attr, message) 
              end
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
            
            if found
              message = record.errors.generate_message(attr_name, :taken, :default => configuration[:message])
              record.errors.add(attr_name, message) 
            end
          end
        end
      end
      
      def validates_format_of(*attr_names)
        configuration = { :on => :save, :with => nil }
        configuration.update(attr_names.extract_options!)

        raise(ArgumentError, "A regular expression must be supplied as the :with option of the configuration hash") unless configuration[:with].is_a?(Regexp)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless value.to_s =~ configuration[:with]
            message = record.errors.generate_message(attr_name, :invalid, :default => configuration[:message], :value => value)
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
            message = record.errors.generate_message(attr_name, :inclusion, :default => configuration[:message], :value => value)
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
            message = record.errors.generate_message(attr_name, :exclusion, :default => configuration[:message], :value => value)
            record.errors.add(attr_name, message) 
          end
        end
      end
      
      def validates_associated(*attr_names)
        configuration = { :on => :save }
        configuration.update(attr_names.extract_options!)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless (value.is_a?(Array) ? value : [value]).inject(true) { |v, r| (r.nil? || r.valid?) && v }
            message = record.errors.generate_message(attr_name, :invalid, :default => configuration[:message], :value => value)
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
              message = record.errors.generate_message(attr_name, :not_a_number, :value => raw_value, :default => configuration[:message])
              record.errors.add(attr_name, message)
              next
            end
            raw_value = raw_value.to_i
          else
           begin
              raw_value = Kernel.Float(raw_value.to_s)
            rescue ArgumentError, TypeError
              message = record.errors.generate_message(attr_name, :not_a_number, :value => raw_value, :default => configuration[:message])
              record.errors.add(attr_name, message)
              next
            end
          end

          numericality_options.each do |option|
            case option
              when :odd, :even
                unless raw_value.to_i.method(ALL_NUMERICALITY_CHECKS[option])[]
                  message = record.errors.generate_message(attr_name, option, :value => raw_value, :default => configuration[:message])
                  record.errors.add(attr_name, message) 
                end
              else
                message = record.errors.generate_message(attr_name, option, :default => configuration[:message], :value => raw_value, :count => configuration[option])
                record.errors.add(attr_name, message) unless raw_value.method(ALL_NUMERICALITY_CHECKS[option])[configuration[option]]
            end
          end
        end
      end
    end
  end
end