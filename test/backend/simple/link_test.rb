# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class I18nSimpleBackendTranslateLinkedTest < Test::Unit::TestCase
  def setup
    @backend = I18n::Backend::Simple.new
    @backend.store_translations 'en', {
      :foo => 'foo',
      :bar => { :baz => 'baz', :link_to_baz => :baz, :link_to_buz => :'boz.buz' },
      :boz => { :buz => 'buz' },
      :link_to_foo => :foo,
      :link_to_bar => :bar,
      :link_to_baz => :'bar.baz'
    }
  end

  def test_translate_calls_translate_if_resolves_to_a_symbol
    assert_equal 'foo', @backend.translate('en', :link_to_foo)
  end

  def test_translate_calls_translate_if_resolves_to_a_symbol2
    assert_equal('baz', @backend.translate('en', :link_to_baz))
  end

  def test_translate_calls_translate_if_resolves_to_a_symbol3
    assert @backend.translate('en', :link_to_bar).key?(:baz)
  end

  def test_translate_calls_translate_if_resolves_to_a_symbol_with_scope_1
    assert_equal('baz', @backend.translate('en', :link_to_baz, :scope => :bar))
  end

  def test_translate_calls_translate_if_resolves_to_a_symbol_with_scope_1
    assert_equal('buz', @backend.translate('en', :'bar.link_to_buz'))
  end
end

