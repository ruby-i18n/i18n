module Tests
  module Backend
    module Simple
      module Setup
        module Base
          def setup
            super
            I18n.backend = I18n::Backend::Simple.new
            backend_store_translations :en, :foo => {:bar => 'bar', :baz => 'baz'}
          end

          def teardown
            super
            I18n.load_path = []
            I18n.backend = nil
          end
        end
      end
    end
  end
end