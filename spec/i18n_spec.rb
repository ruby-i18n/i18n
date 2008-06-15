require File.dirname(__FILE__) + '/spec_helper.rb'
$:.unshift File.dirname(__FILE__) + '/../lib/'

require 'i18n'

describe I18n::Translation, 'localize with minimal backend' do
  it 'should respond_to :translate' do
    should respond_to(:t)
  end
  
  it 'should alias :translate as :t' do
    should respond_to(:t)
  end
  
  it 'should return the default' do
    translate(:test, :default => 'default').should == 'default'
  end
  
  it 'should interpolate the default value if an interpolation hash is given' do
    translate(:too_long, :default => 'The field {{name}} is to long', :name => 'login').should == 'The field login is to long'
  end
  
  it 'should not interpolate the default value if no interpolation hash is given' do
    translate(:too_long, :default => 'The field {{name}} is to long').should == 'The field {{name}} is to long'
  end  
  
  it 'should ignore keys and scopes' do
    translate(:name, :keys => [:name], :scope => :fields, :default => 'Name').should == 'Name'
    translate(:name, :scope, :default => 'Name').should == 'Name'
    translate(:name, :default => 'Name').should == 'Name'
  end
  
  it 'should use plural count for interpolation' do
    translate(:new_messages, :default => 'You have {{count}} new messages', :count => 5).should == 'You have 5 new messages'
  end
end


# describe I18n::Translation, 'localize with a backend available' do
#   
#   before do
#     @backend = I18n.backend = mock('Backend')
#   end
#   
#   it 'should use the backend to look up the keys' do
#     @backend.should_receive(:lookup).once.with([:scope, :key]).and_return('value')
#     :key.translate(:scope).should == 'value'
#   end
#   
#   it 'should use the backend to do pluralization' do
#     @backend.should_receive(:lookup).and_return('pluralize this')
#     @backend.should_receive(:pluralize).once.with('pluralize this', 4).and_return('4 times')
#     :something.translate(4).should == '4 times'
#   end
#   
#   it 'should use the backend\'s interpolation method' do
#     @backend.should_receive(:lookup).and_return('looked up {{stuff}}')
#     @backend.should_receive(:interpolate).once.with('looked up {{stuff}}', :stuff => 'my stuff').and_return('interpolated stuff')
#     :something.translate(:stuff => 'my stuff').should == 'interpolated stuff'
#   end
#   
#   it 'should respect the key added by a symbol' do
#     @backend.should_receive(:lookup).once.with([:key]).and_return('value')
#     :key.translate.should == 'value'
#   end
#   
# end

describe I18n::Translation, 'interpolation' do
  before do
    @backend = I18n::Backend::Minimal
  end
  
  it 'should provide a simple way to interpolate values' do
    @backend.send(:interpolate, 'Welcome {{user}}', :user => 'Mr. X').should == 'Welcome Mr. X'
    @backend.send(:interpolate, 'Welcome to {{place}} {{user}}', :place => 'your home', :user => 'Mr. X').should == 'Welcome to your home Mr. X'
  end
  
  it 'should work with empty interpolation keys' do
    @backend.send(:interpolate, "you'll see {{nothing}}", :nothing => nil).should == "you'll see "
  end
  
  it 'should respect a escape sequence' do
    @backend.send(:interpolate, 'just a \\{{test}}').should == 'just a {{test}}'
    @backend.send(:interpolate, 'another \\{{test}} or {{something}}', :something => 'what?').should == 'another {{test}} or what?'
    @backend.send(:interpolate, 'another {{thing}} or \\{{something}}', :thing => 'test').should == 'another test or {{something}}'
  end
  
  it 'should respect escape sequences with interpolation keys of the same name' do
    @backend.send(:interpolate, 'just a \\{{test}} but also a {{test}}', :test => 'spec').should == 'just a {{test}} but also a spec'
  end
  
  # it 'should raise an exception if an interpolation key is missing and I18n.raise_exceptions is true' do
  #   I18n.raise_exceptions = true
  #   lambda { :test.send(:interpolate, "I am {{missing}}") }.should raise_error(I18n::MissingInterpolationKeyError)
  #   lambda { :test.send(:interpolate, "{{user}} is {{missing}}", :user => 'Mr. X') }.should raise_error(I18n::MissingInterpolationKeyError)
  #   lambda { :test.send(:interpolate, "\\{{escaped}} is {{missing}}") }.should raise_error(I18n::MissingInterpolationKeyError)
  # end
  # 
  # it "shouldn't raise an exception for missing interpolation keys if I18n.raise_exceptions is false" do
  #   I18n.raise_exceptions = false
  #   lambda { :test.send(:interpolate, "I am {{missing}}") }.should_not raise_error(I18n::MissingInterpolationKeyError)
  #   lambda { :test.send(:interpolate, "{{user}} is {{missing}}", :user => 'Mr. X') }.should_not raise_error(I18n::MissingInterpolationKeyError)
  #   lambda { :test.send(:interpolate, "\\{{escaped}} is {{missing}}") }.should_not raise_error(I18n::MissingInterpolationKeyError)
  # end
  
end
