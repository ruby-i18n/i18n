# encoding: utf-8
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../')); $:.uniq!
require 'test_helper'

setup_rufus_tokyo

require 'active_support/all'

class I18nBackendKeyValueTest < Test::Unit::TestCase
  def setup_backend!(subtree=true)
    I18n.backend = I18n::Backend::KeyValue.new(Rufus::Tokyo::Cabinet.new('*'), subtree)
    store_translations(:en, :foo => { :bar => 'bar', :baz => 'baz' })
  end

  test "store_translations handle subtrees by default" do
    setup_backend!
    assert_equal({ :bar => 'bar', :baz => 'baz' }, I18n.t("foo"))
  end

  test "store_translations merge subtrees accordingly" do
    setup_backend!
    store_translations(:en, :foo => { :baz => "BAZ"})
    assert_equal('BAZ', I18n.t("foo.baz"))
    assert_equal({ :bar => 'bar', :baz => 'BAZ' }, I18n.t("foo"))
  end

  test "store_translations does not handle subtrees if desired" do
    setup_backend!(false)
    assert_raise I18n::MissingTranslationData do
      I18n.t("foo", :raise => true)
    end
  end

end if defined?(Rufus::Tokyo::Cabinet)