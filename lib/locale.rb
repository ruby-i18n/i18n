class Locale < String
  include I18n::TranslationMixin
  
  @@instances = {}
  @@default_code = 'en-US'
  
  class << self
    def use(code)
      Thread.current[:locale] = Locale[code]
    end
    
    def current
      Thread.current[:locale] ||= self[@@default_code]
    end
    
    def [](code)
      @@instances[code] ||= Locale.new(code)
    end
  end
  
  def initialize(code)
    super code.to_s
  end

  protected
  
    def typify_localization_args(args)      
      args.insert(1, self) if args[1].nil? || args[1].is_a?(Hash)
      args
    end
end