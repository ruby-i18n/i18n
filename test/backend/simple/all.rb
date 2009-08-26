# encoding: utf-8

Dir[File.dirname(__FILE__) + '/*_test.rb'].each do |file|
  require file
end
