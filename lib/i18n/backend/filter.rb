module I18n
  module Backend
    class Filter
      attr_accessor :translation
      attr_reader   :context

      def initialize(translation, context=nil)
        @translation = translation
        @context     = context
      end

      # This method should determine if the filter is applicable or not
      # Should be implemented and return a boolean
      def applicable?
        raise NotImplementedError
      end

      # This method should do all of the processing by modifying the
      # translation object directly
      # Should be implemented
      def call
        raise NotImplementedError
      end
    end
  end
end