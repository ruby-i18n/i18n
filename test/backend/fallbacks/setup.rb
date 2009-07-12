module Tests
  module Backend
    module Fallbacks
      module Setup
        def setup
          super
          class << I18n.backend
            include I18n::Backend::Fallbacks
          end
        end
      end
    end
  end
end