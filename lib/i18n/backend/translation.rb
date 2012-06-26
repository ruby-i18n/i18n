module I18n
  module Backend
    class Translation
      attr_accessor :locale, :key, :content, :scope, :default, :interpolations

      def initialize(args)
        @locale         = args.delete :locale
        @key            = args.delete :key
        @scope          = args.delete :scope
        @default        = args.delete :default
        @interpolations = args.except(*RESERVED_KEYS)
        @content        = nil
      end

      def count
        interpolations[:count]
      end
    end
  end
end