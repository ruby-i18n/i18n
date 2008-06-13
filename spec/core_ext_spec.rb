require File.dirname(__FILE__) + '/spec_helper.rb'

describe Symbol, 'with I18n translation module mixed in' do
  it 'should respond to #translate and the #t shortcut' do
    :test.should respond_to(:translate, :t)
  end
  
  it 'should typify itself as another nested key' do
    :test.send(:typify_localization_options, {:keys => []}).should == {:keys => [:test]}
    :test.send(:typify_localization_options, {:keys => [:scope]}).should == {:keys => [:scope, :test]}
  end  
end

describe Time, 'with I18n localization module mixed in' do
  it 'should respond to #localize and the #l shortcut' do
    Time.now.should respond_to(:localize, :l)
  end  
end

describe Date, 'with I18n localization module mixed in' do
  it 'should respond to #localize and the #l shortcut' do
    Date.new.should respond_to(:localize, :l)
  end
end

describe DateTime, 'with I18n localization module mixed in' do
  it 'should respond to #localize and the #l shortcut' do
    DateTime.new.should respond_to(:localize, :l)
  end
end
