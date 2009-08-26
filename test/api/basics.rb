# encoding: utf-8

module Tests
  module Backend
    module Api
      module Basics
        def test_available_locales
          backend_store_translations 'de', :foo => 'bar'
          backend_store_translations 'en', :foo => 'foo'
          assert_equal ['de', 'en'], I18n.backend.available_locales.map{|locale| locale.to_s }.sort
        end
      end
    end
  end
end