# encoding: utf-8
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../')); $:.uniq!
require 'test_helper'

class I18nBackendHelpersTest < Test::Unit::TestCase
  def setup
    @backend = I18n::Backend::Simple.new
  end
  
  test "deep_symbolize_keys" do
    result = @backend.deep_symbolize_keys('foo' => { 'bar' => { 'baz' => 'bar' } })
    expected = {:foo => {:bar => {:baz => 'bar'}}}
    assert_equal expected, result
  end
end