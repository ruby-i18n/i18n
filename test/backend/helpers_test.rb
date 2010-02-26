# encoding: utf-8
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../')); $:.uniq!
require 'test_helper'

class I18nBackendHelpersTest < Test::Unit::TestCase
  def setup
    @backend = I18n::Backend::Simple.new
  end
  
  test "wind_keys" do
    hash = { "a" => { "b" => { "c" => "d", "e" => "f" }, "g" => "h" }, :"i.a" => "j", "g.a" => "h"}
    expected = { :"a.b.c" => "d", :"a.b.e" => "f", :"a.g" => "h", :"i.a" => "j", :"g.a" => "h" }
    assert_equal expected, @backend.wind_keys(hash)
  end

  test "unwind_keys" do
    hash = { "a.b.c" => "d", :"a.b.e" => "f", :"a.g" => "h", "i" => "j" }
    expected = { "a" => { "b" => { "c" => "d", "e" => "f" }, "g" => "h" }, "i" => "j"}
    assert_equal expected, @backend.unwind_keys(hash)
  end

  test "deep_symbolize_keys" do
    result = @backend.deep_symbolize_keys('foo' => { 'bar' => { 'baz' => 'bar' } })
    expected = {:foo => {:bar => {:baz => 'bar'}}}
    assert_equal expected, result
  end
end