module I18n
  module Backend
    class Translation
      attr_accessor :locale, :key, :content, :scope, :count, :default, :interpolations

      def initialize(args)
        @locale         = args.delete :locale
        @key            = args.delete :key
        @scope          = args.delete :scope
        @count          = args.delete :count
        @default        = args.delete :default
        @interpolations = args.except(*RESERVED_KEYS)
        @content        = nil
      end
    end
  end
end