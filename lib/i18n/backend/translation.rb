module I18n
  module Backend
    class Translation
      attr_accessor :locale, :key, :content, :scope, :default, :interpolations, :context

      def initialize(args)
        @locale         = args.delete :locale
        @key            = args.delete :key
        @scope          = args.delete :scope
        @default        = args.delete :default
        @interpolations = args.except(*RESERVED_KEYS)
        @content        = nil

        # Context should be a reserved key
        # Not deleting this arg here so as not to break the existing API
        @context        =  args[:context]
      end

      def count
        interpolations[:count]
      end
    end
  end
end