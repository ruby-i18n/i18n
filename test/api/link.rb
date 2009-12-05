# encoding: utf-8

module Tests
  module Api
    module Link
      define_method "test linked lookup: given the key resolves to a symbol it looks up the symbol" do
        setup_linked_translations
        assert_equal 'foo', I18n.backend.translate('en', :link_to_foo)
      end

      define_method "test linked lookup: given the key resolves to a dot-separated symbol it looks up the dot-separated symbol (1)" do
        setup_linked_translations
        assert_equal('baz', I18n.backend.translate('en', :link_to_baz))
      end
      
      define_method "test linked lookup: given the key resolves to a dot-separated symbol it looks up the dot-separated symbol (2)" do
        setup_linked_translations
        assert_equal('buz', I18n.backend.translate('en', :'bar.link_to_buz'))
      end
      
      define_method "test linked lookup: given a scope and the key resolves to a symbol it looks up the symbol within the scope" do
        setup_linked_translations
        assert_equal('baz', I18n.backend.translate('en', :link_to_baz, :scope => :bar))
      end
      
      protected

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
