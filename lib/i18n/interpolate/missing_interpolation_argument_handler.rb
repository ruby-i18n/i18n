module I18n
  # It is responsible for raising an exception or providing default value in case
  # of missing interpolation argument.
  class MissingInterpolationArgumentHandler
    module Implementation
      attr_reader :defaults

      # == Options:
      # * :raise_exception - (default is true) Defines whether MissingInterpolationArgument
      #   should be raised or exception message should be returned instead.
      # * :rescue_format - (:html (default), :text) Defines in what format exception message
      #   should be returned. Ignored if :raise_exception is true.
      def initialize(options = {})
        defaults = {:raise_exception => true, :rescue_format => :html}
        @defaults = defaults.merge(options)
      end

      # Return String or raise MissingInterpolationArgument exception.
      def call(missing_key, provided_hash, interpolated_string)
        exception = MissingInterpolationArgument.new(missing_key, provided_hash, interpolated_string)
        if defaults[:raise_exception]
          raise exception
        else
          defaults[:rescue_format] == :html ? exception.html_message : "<#{exception.message}>"
        end
      end
    end
    include Implementation
  end
end
