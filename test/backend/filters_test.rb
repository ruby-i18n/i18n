require 'test_helper'

class ChangeKeyFilter < I18n::Filters::Base
  def applies?
    true
  end

  def call
    translation.key = :changed
  end
end

class ChangeInterpolationsFilter < I18n::Filters::Base
  def applies?
    true
  end

  def call
    translation.interpolations[:name] = 'Maru' 
  end
end

class FilterOne < I18n::Filters::Base
  def applies?
    true
  end

  def call
    translation.content = 'filter one'
  end
end

class FilterTwo < I18n::Filters::Base
  def applies?
    true
  end

  def call
    translation.content << ' - filter two'
  end
end

class FilterNotApplicable < I18n::Filters::Base
  def applies?
    false
  end

  def call
    translation.key = :no_more_biscuits
    translation.content = "Oh noez!"
  end
end

class BeforeLookupFiltersTest < Test::Unit::TestCase
  test "it applies all applicable filters" do
    I18n.backend.store_translations(:en, :foo => 'bar')
    I18n.backend.store_translations(:en, :changed => 'O-hai!, %{name}')
    I18n.filter_chain.expects(:before_lookup).returns([ChangeKeyFilter, ChangeInterpolationsFilter, FilterNotApplicable])
    assert_equal('O-hai!, Maru', I18n.t(:foo))
  end
end

class AfterLookupFiltersTest < Test::Unit::TestCase
  test "it applies all applicable filters" do
    I18n.backend.store_translations(:en, :foo => 'bar')
    I18n.filter_chain.expects(:after_lookup).returns([FilterOne, FilterTwo, FilterNotApplicable])
    assert_equal('filter one - filter two', I18n.t(:foo))
  end
end