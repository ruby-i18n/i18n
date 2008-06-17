module TranslateHelper
  def translate(*args)
    # inserts the current request locale to the argument list if no locale
    # has been passed, the request is available and the request locale set
    unless args.size > 2
      locale = request.locale if respond_to(:locale)
      args[1].is_a?(Hash) ? args.insert(1, locale) : args[1] = locale if locale
    end
    I18n.translate *args
  end
  alias :t :translate
end