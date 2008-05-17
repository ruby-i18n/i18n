require File.dirname(__FILE__) + '/spec_helper.rb'


describe I18n::TranslationMixin, 'localize without backend' do
  
  before do
    I18n.backend = nil
  end
  
  it 'should return the default' do
    :test.localize('default').should == 'default'
  end
  
  it 'should alias :localize as :l' do
    :test.l('default').should == 'default'
  end  
  
  it 'should interpolate the default value if an interpolation hash is given' do
    :to_long.localize('The field {{name}} is to long', :name => 'login').should == 'The field login is to long'
  end
  
  it 'should not interpolate the default value if no interpolation hash is given' do
    :to_long.localize('The field {{name}} is to long').should == 'The field {{name}} is to long'
  end  
  
  it 'should ignore keys and scopes' do
    :name.localize(:key => :name, :scope => :fields, :default => 'Name').should == 'Name'
    :name.localize(:scope, 'Name').should == 'Name'
    :name.localize('Name').should == 'Name'
  end
  
  it 'should use plural counts only for interpolation' do
    :new_messages.localize('You have {{count}} new messages', 5).should == 'You have 5 new messages'
  end
  
  it 'should respect the default value added by a string' do
    'default'.localize.should == 'default'
  end
  
end


describe I18n::TranslationMixin, 'localize with a backend available' do
  
  before do
    @backend = I18n.backend = mock('Backend')
  end
  
  it 'should use the backend to look up the keys' do
    @backend.should_receive(:lookup).once.with([:scope, :key]).and_return('value')
    :key.localize(:scope).should == 'value'
  end
  
  it 'should use the backend to do pluralization' do
    @backend.should_receive(:lookup).and_return('pluralize this')
    @backend.should_receive(:pluralize).once.with('pluralize this', 4).and_return('4 times')
    :something.localize(4).should == '4 times'
  end
  
  it 'should use the backend\'s interpolation method' do
    @backend.should_receive(:lookup).and_return('looked up {{stuff}}')
    @backend.should_receive(:interpolate).once.with('looked up {{stuff}}', :stuff => 'my stuff').and_return('interpolated stuff')
    :something.localize(:stuff => 'my stuff').should == 'interpolated stuff'
  end
  
  it 'should respect the key added by a symbol' do
    @backend.should_receive(:lookup).once.with([:key]).and_return('value')
    :key.localize.should == 'value'
  end
  
end


describe I18n::TranslationMixin, 'explicit_options?' do
  
  it 'should regard hashes with reserved keys as explict options' do
    :test.send(:explicit_options?, {:key => :name}).should be_true
    :test.send(:explicit_options?, {:default => 'def'}).should be_true
    :test.send(:explicit_options?, {:values => {:a => 'b'}}).should be_true
    :test.send(:explicit_options?, {:plural => 5}).should be_true
    :test.send(:explicit_options?, {:scope => :name}).should be_true
  end
  
  it 'should reject hashes without reserved keys' do
    :test.send(:explicit_options?, {:name => 'Mr. X'}).should be_false
    :test.send(:explicit_options?, {:group => 'Programmers'}).should be_false
  end
  
  it "should reject everything that's not a hash" do
    :test.send(:explicit_options?, []).should be_false
    :test.send(:explicit_options?, 'test').should be_false
    :test.send(:explicit_options?, :test).should be_false
  end
  
end


describe I18n::TranslationMixin, 'parse_args_by_type' do
  
  it 'should parse all symbols as keys' do
    :test.send(:parse_args_by_type, :key)[:keys].should == [:key]
    :test.send(:parse_args_by_type, 'something', :key, 123)[:keys].should == [:key]
    :test.send(:parse_args_by_type, :key1, :key2)[:keys].should == [:key1, :key2]
    :test.send(:parse_args_by_type, 'default', :key1, 2, :key2, 4)[:keys].should == [:key1, :key2]
  end
  
  it 'should parse the first detected string as a default value' do
    :test.send(:parse_args_by_type, 'default')[:default].should == 'default'
    :test.send(:parse_args_by_type, :a_key, 'default', 123)[:default].should == 'default'
    :test.send(:parse_args_by_type, 'first', 'second')[:default].should == 'first'
    :test.send(:parse_args_by_type, :a_key, 'first', 123, 'second')[:default] == 'first'
  end
  
  it 'should parse the first detected integer as pluralization count' do
    :test.send(:parse_args_by_type, 1)[:plural].should == 1
    :test.send(:parse_args_by_type, :key, 'default', 2)[:plural].should == 2
    :test.send(:parse_args_by_type, 1, 2, 3)[:plural].should == 1
    :test.send(:parse_args_by_type, :key, 1, 'def', 2, :key2, 3)[:plural] == 1
  end
  
  it 'should parse the first found hash as interpolation values' do
    :test.send(:parse_args_by_type, {:user => 'Mr. X'})[:values].should == {:user => 'Mr. X'}
    :test.send(:parse_args_by_type, {}, {:user => 'Mr. X'})[:values].should == {}
    :test.send(:parse_args_by_type, :key, {:a => 'b'}, 'def', {:c => 'd'})[:values].should == {:a => 'b'}
  end
  
end


describe I18n::TranslationMixin, 'parse_args_by_keys' do
  
  it 'should pass through the default value, the plural count and the interpolation hash' do
    :test.send(:parse_args_by_keys, {:default => 'def'})[:default].should == 'def'
    :test.send(:parse_args_by_keys, {:plural => 43})[:plural].should == 43
    :test.send(:parse_args_by_keys, {:values => {:a => 'b'}})[:values].should == {:a => 'b'}
  end
  
  it 'should combine the :key and :scope keys to the :keys option with the scope first' do
    :test.send(:parse_args_by_keys, {:key => :key_name})[:keys].should == [:key_name]
    :test.send(:parse_args_by_keys, {:scope => :scope_name})[:keys].should == [:scope_name]
    :test.send(:parse_args_by_keys, {:key => :key_name, :scope => :scope_name})[:keys].should == [:scope_name, :key_name]
  end
  
  it 'should also combine arrays of the :key and :scope keys to the :keys option' do
    :test.send(:parse_args_by_keys, {:key => [:key1, :key2], :scope => [:scope1, :scope2]})[:keys].should == [:scope1, :scope2, :key1, :key2]
  end
  
end


describe I18n::TranslationMixin, 'check_options! with an available backend' do
  
  before do
    I18n.backend = 'fake backend'
  end
  
  it 'should not complain if all options have proper types' do
    lambda { :test.send(:check_options!, {:keys => [:key], :default => nil,   :plural => nil, :values => nil})         }.should_not raise_error
    lambda { :test.send(:check_options!, {:keys => [],     :default => 'def', :plural => nil, :values => nil})         }.should_not raise_error
    lambda { :test.send(:check_options!, {:keys => [],     :default => nil,   :plural => 2,   :values => nil})         }.should_not raise_error
    lambda { :test.send(:check_options!, {:keys => [],     :default => nil,   :plural => 2.5, :values => nil})         }.should_not raise_error
    lambda { :test.send(:check_options!, {:keys => [],     :default => nil,   :plural => nil, :values => {:a => 'b'}}) }.should_not raise_error
    lambda { :test.send(:check_options!, {:keys => [:key], :default => 'def', :plural => 2, :values => {:a => 'b'}})   }.should_not raise_error
  end
  
  it "should complain if :keys isn't an array" do
    lambda { :test.send(:check_options!, {:keys => 'something', :default => nil, :plural => nil, :values => nil}) }.should raise_error(ArgumentError)
  end
  
  it "should complain if :default isn't a string" do
    lambda { :test.send(:check_options!, {:keys => [], :default => :not_a_string, :plural => nil, :values => nil}) }.should raise_error(ArgumentError)
  end
  
  it "should complain if :plural isn't an Numeric" do
    lambda { :test.send(:check_options!, {:keys => [], :default => nil, :plural => 'tree', :values => nil}) }.should raise_error(ArgumentError)
  end
  
  it "should complain if :values isn't a hash" do
    lambda { :test.send(:check_options!, {:keys => [], :default => nil, :plural => nil, :values => [1, 2, 3]}) }.should raise_error(ArgumentError)
  end
  
end


describe I18n::TranslationMixin, 'check_options! without an backend' do
  
  before do
    I18n.backend = nil
  end
  
  it 'should not complain if no backend is available but a default value is given' do
    lambda { :test.send(:check_options!, {:keys => [], :default => 'default', :plural => nil, :values => nil}) }.should_not raise_error
  end
  
  it 'should complain if no backend is available and no default value is given' do
    lambda { :test.send(:check_options!, {:keys => [:name], :default => nil, :plural => nil, :values => nil}) }.should raise_error(ArgumentError)
  end
  
end


describe I18n::TranslationMixin, 'interpolation' do
  
  it 'should provide a simple way to interpolate values' do
    :test.send(:interpolate, 'Welcome {{user}}', :user => 'Mr. X').should == 'Welcome Mr. X'
    :test.send(:interpolate, 'Welcome to {{place}} {{user}}', :place => 'your home', :user => 'Mr. X').should == 'Welcome to your home Mr. X'
  end
  
  it 'should work with empty interpolation keys' do
    :test.send(:interpolate, "you'll see {{nothing}}", :nothing => nil).should == "you'll see "
  end
  
  it 'should respect a escape sequence' do
    :test.send(:interpolate, 'just a \\{{test}}').should == 'just a {{test}}'
    :test.send(:interpolate, 'another \\{{test}} or {{something}}', :something => 'what?').should == 'another {{test}} or what?'
    :test.send(:interpolate, 'another {{thing}} or \\{{something}}', :thing => 'test').should == 'another test or {{something}}'
  end
  
  it 'should respect escape sequences with interpolation keys of the same name' do
    :test.send(:interpolate, 'just a \\{{test}} but also a {{test}}', :test => 'spec').should == 'just a {{test}} but also a spec'
  end
  
  it 'should raise an exception if an interpolation key is missing and I18n.raise_exceptions is true' do
    I18n.raise_exceptions = true
    lambda { :test.send(:interpolate, "I am {{missing}}") }.should raise_error(I18n::MissingInterpolationKeyError)
    lambda { :test.send(:interpolate, "{{user}} is {{missing}}", :user => 'Mr. X') }.should raise_error(I18n::MissingInterpolationKeyError)
    lambda { :test.send(:interpolate, "\\{{escaped}} is {{missing}}") }.should raise_error(I18n::MissingInterpolationKeyError)
  end
  
  it "shouldn't raise an exception for missing interpolation keys if I18n.raise_exceptions is false" do
    I18n.raise_exceptions = false
    lambda { :test.send(:interpolate, "I am {{missing}}") }.should_not raise_error(I18n::MissingInterpolationKeyError)
    lambda { :test.send(:interpolate, "{{user}} is {{missing}}", :user => 'Mr. X') }.should_not raise_error(I18n::MissingInterpolationKeyError)
    lambda { :test.send(:interpolate, "\\{{escaped}} is {{missing}}") }.should_not raise_error(I18n::MissingInterpolationKeyError)
  end
  
end
