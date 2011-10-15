require 'test_helper'

class I18nOverrideTest < Test::Unit::TestCase
  module OverrideInverse

    def translate(*args)
      super(*args).reverse
    end
    alias :t :translate

  end

  module OverrideSignature

    def translate(*args)
      args.first
    end
    alias :t :translate

  end

  def setup
    I18n.backend = I18n::Backend::Simple.new
    I18n.extend OverrideInverse
    super
  end

  test "make sure modules can overwrite I18n methods" do
    I18n.backend.store_translations('en', :foo => 'bar')

    assert_equal 'rab', I18n.translate(:foo, :locale => 'en')
    assert_equal 'rab', I18n.t(:foo, :locale => 'en')
    assert_equal 'rab', I18n.translate!(:foo, :locale => 'en')
    assert_equal 'rab', I18n.t!(:foo, :locale => 'en')
  end

  test "make sure modules can overwrite I18n signature" do
    assert I18n.translate("Hello", "Welcome message on home page", :tokenize => true) # tr8n example
  end

end
