# encoding: utf-8

module Tests
  module Backend
    module Api
      module Link
        def test_translate_calls_translate_if_resolves_to_a_symbol
          setup_linked_translations
          assert_equal 'foo', I18n.backend.translate('en', :link_to_foo)
        end

        def test_translate_calls_translate_if_resolves_to_a_symbol2
          setup_linked_translations
          assert_equal('baz', I18n.backend.translate('en', :link_to_baz))
        end

        def test_translate_calls_translate_if_resolves_to_a_symbol3
          setup_linked_translations
          assert I18n.backend.translate('en', :link_to_bar).key?(:baz)
        end

        def test_translate_calls_translate_if_resolves_to_a_symbol_with_scope_1
          setup_linked_translations
          assert_equal('baz', I18n.backend.translate('en', :link_to_baz, :scope => :bar))
        end

        def test_translate_calls_translate_if_resolves_to_a_symbol_with_scope_1
          setup_linked_translations
          assert_equal('buz', I18n.backend.translate('en', :'bar.link_to_buz'))
        end

        private
  
          def setup_linked_translations
            I18n.backend.store_translations 'en', {
              :foo => 'foo',
              :bar => { :baz => 'baz', :link_to_baz => :baz, :link_to_buz => :'boz.buz' },
              :boz => { :buz => 'buz' },
              :link_to_foo => :foo,
              :link_to_bar => :bar,
              :link_to_baz => :'bar.baz'
            }
          end
      end
    end
  end
end