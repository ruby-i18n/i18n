require File.expand_path(File.dirname(__FILE__) + '/test_helper')

# thanks to Masao's String extensions these should work the same in
# Ruby 1.8 (patched) and Ruby 1.9 (native)

class I18nStringTest < Test::Unit::TestCase
  define_method :"test: String interpolates a single argument" do
    assert_equal "Masao", "%s" % "Masao"
  end
  
  define_method :"test: String interpolates an array argument" do
    assert_equal "Masao Mutoh", "%s %s" % %w(Masao Mutoh)
  end
  
  define_method :"test: String interpolates a hash argument w/ named placeholders" do
    assert_equal "Masao Mutoh", "%{first} %{last}" % { :first => 'Masao', :last => 'Mutoh' }
  end
  
  define_method :"test: String interpolates named placeholders with sprintf syntax" do
    assert_equal "10, 43.4", "%<integer>d, %<float>.1f" % {:integer => 10, :float => 43.4}
  end
  
  define_method :"test: String interpolation raises an ArgumentError when the string has extra placeholders (Array)" do
    assert_raises(ArgumentError) do # Ruby 1.9 msg: "too few arguments"
      "%s %s" % %w(Masao) 
    end
  end
  
  define_method :"test: String interpolation raises a KeyError when the string has extra placeholders (Hash)" do
    assert_raises(KeyError) do # Ruby 1.9 msg: "key not found"
      "%{first} %{last}" % { :first => 'Masao' }
    end
  end
  
  define_method :"test: String interpolation does not raise when passed extra values (Array)" do
    assert_nothing_raised do 
      assert_equal "Masao", "%s" % %w(Masao Mutoh)
    end
  end
  
  define_method :"test: String interpolation does not raise when passed extra values (Hash)" do
    assert_nothing_raised do
      assert_equal "Masao Mutoh", "%{first} %{last}" % { :first => 'Masao', :last => 'Mutoh', :salutation => 'Mr.' }
    end
  end
  
  define_method :"test: % acts as escape character in String interpolation" do
    assert_equal "%{first}", "%%{first}" % { :first => 'Masao' }
  end
end