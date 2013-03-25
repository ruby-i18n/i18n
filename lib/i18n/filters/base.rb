class I18n::Filters::Base
  attr_accessor :translation

  def initialize(translation)
    @translation = translation
  end

  # This method should determine if the filter is applicable or not
  # Should be implemented and return a boolean
  def applies?
    raise NotImplementedError
  end

  # This method should do all of the processing by modifying the
  # translation object directly
  # Should be implemented
  def call
    raise NotImplementedError
  end
end
