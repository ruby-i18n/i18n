# encoding: utf-8
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../')); $:.uniq!
require 'test_helper'
require 'backend/simple_test'

class I18nBackendFastTest < I18nBackendSimpleTest
  class FastBackend
    include I18n::Backend::Base
    include I18n::Backend::Fast
  end
  
  def setup
    super
    I18n.backend = FastBackend.new
  end
end

class I18nBackendFastSpecificTest < Test::Unit::TestCase
  class FastBackend
    include I18n::Backend::Base
    include I18n::Backend::Fast
  end
  
  def setup
    @backend = FastBackend.new
  end

  def assert_flattens(expected, nested)
    assert_equal expected, @backend.send(:wind_keys, nested, nil, true)
  end

  test "hash flattening works" do
    assert_flattens(
      {:a=>'a', :b=>{:c=>'c', :d=>'d', :f=>{:x=>'x'}}, :"b.f" => {:x=>"x"}, :"b.c"=>"c", :"b.f.x"=>"x", :"b.d"=>"d"},
      {:a=>'a', :b=>{:c=>'c', :d=>'d', :f=>{:x=>'x'}}}
    )
    assert_flattens({:a=>{:b =>['a', 'b']}, :"a.b"=>['a', 'b']}, {:a=>{:b =>['a', 'b']}})
  end

  test "pluralization logic and lookup works" do
    counts_hash = {:zero => 'zero', :one => 'one', :other => 'other'}
    @backend.store_translations :en, {:a => counts_hash}
    assert_equal 'one', @backend.translate(:en, :a, :count => 1)
  end

  test "translation subtree retrieval" do
    @backend.store_translations :en, :a => {:foo => 'bar'}
    assert_equal({:foo => 'bar'}, @backend.translate(:en, :a))
  end
end
