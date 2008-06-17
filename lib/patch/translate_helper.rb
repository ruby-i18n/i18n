module TranslateHelper
  def translate(*args)
    unless args.size > 2
      locale = request.locale if respond_to(:locale)
      args[1].is_a?(Hash) ? args.insert(1, locale) : args[1] = locale if locale
    end
    I18n.translate *args
  end
  alias :t :translate
end