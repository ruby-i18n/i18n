# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class HashWindTest < Test::Unit::TestCase
  def test_wind
    hash = { "a" => { "b" => { "c" => "d", "e" => "f" }, "g" => "h" }, "i" => "j"}
    expected = { "a.b.c" => "d", "a.b.e" => "f", "a.g" => "h", "i" => "j" }
    assert_equal expected, hash.wind
  end

  def test_unwind
    hash = { "a.b.c" => "d", "a.b.e" => "f", "a.g" => "h", "i" => "j" }
    expected = { "a" => { "b" => { "c" => "d", "e" => "f" }, "g" => "h" }, "i" => "j"}
    assert_equal expected, hash.unwind
  end
end