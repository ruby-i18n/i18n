# encoding: utf-8
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../')); $:.uniq!
require 'test_helper'
require 'backend/simple_test'

class I18nBackendMemoizeTest < I18nBackendSimpleTest
  class MemoizeBackend
    include I18n::Backend::Base
    include I18n::Backend::Memoize
  end
  
  def setup
    I18n.backend = MemoizeBackend.new
    super
  end
end