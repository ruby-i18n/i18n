module I18n
  # This is the generic localization mixin suitable for almost any object. It
  # just asks the backend to localize the object or (if no backend is available)
  # simply returns self. Useful for Date, Time, ect.
  module Localization
    # Just ask the backend to localize this object. Simply returns self if no
    # backend is available.
    def localize(*args)
      if I18n.backend.respond_to? :localize
        I18n.backend.localize(self, *args)
      else
        self
      end
    end
    
    alias :l :localize
  end
end
