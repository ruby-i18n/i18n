# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'i18n/backend/pluralization'

class I18nPluralizationBackendTest < Test::Unit::TestCase
  def setup
    I18n.backend = I18n::Backend::Simple.new
    I18n.backend.meta_class.send(:include, I18n::Backend::Pluralization)
    @pluralizer = lambda { |n| n == 1 ? :one : n == 0 || (2..10).include?(n % 100) ? :few : (11..19).include?(n % 100) ? :many : :other }
    backend_store_translations(:foo, :i18n => { :pluralize => @pluralizer })
    @entry = { :zero => 'zero', :one => 'one', :few => 'few', :many => 'many', :other => 'other' }
  end

  define_method :"test: pluralization picks a pluralizer from :'i18n.pluralize'" do
    assert_equal @pluralizer, I18n.backend.send(:pluralizer, :foo)
  end

  define_method :"test: pluralization picks :one for 1" do
    assert_equal 'one', I18n.t(:count => 1, :default => @entry, :locale => :foo)
  end

  define_method :"test: pluralization picks :few for 2" do
    assert_equal 'few', I18n.t(:count => 2, :default => @entry, :locale => :foo)
  end

  define_method :"test: pluralization picks :many for 11" do
    assert_equal 'many', I18n.t(:count => 11, :default => @entry, :locale => :foo)
  end

  define_method :"test: pluralization picks zero for 0 if the key is contained in the data" do
    assert_equal 'zero', I18n.t(:count => 0, :default => @entry, :locale => :foo)
  end

  define_method :"test: pluralization picks few for 0 if the key is not contained in the data" do
    @entry.delete(:zero)
    assert_equal 'few', I18n.t(:count => 0, :default => @entry, :locale => :foo)
  end
end