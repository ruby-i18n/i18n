# encoding: utf-8

base = File.dirname(__FILE__)
$LOAD_PATH.unshift base

Dir["#{base}/**/*_test.rb"].sort.each do |file|
  require file.sub(/^#{base}\/(.*)\.rb$/, '\1')
end
