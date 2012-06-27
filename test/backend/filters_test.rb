require 'test_helper'

class FilterOne < I18n::Filters::Base
  def applicable?
    true
  end

  def call
    translation.content = 'filter one'
  end
end

class FilterTwo < I18n::Filters::Base
  def applicable?
    true
  end

  def call
    translation.content << ' - filter two'
  end
end

class FilterNotApplicable < I18n::Filters::Base
  def applicable?
    false
  end

  def call
    translation.content = "Oh noez!"
  end
end

class FiltersTest < Test::Unit::TestCase
  test "it applies all applicable filters" do
    I18n.backend.store_translations(:en, :foo => 'bar')
    I18n.expects(:filters).returns([FilterOne, FilterTwo, FilterNotApplicable])
    assert_equal('filter one - filter two', I18n.t(:foo))
  end
end