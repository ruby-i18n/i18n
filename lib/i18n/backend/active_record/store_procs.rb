module I18n
  module Backend
    class ActiveRecord < Base
      module StoreProcs
        class << self
          def included(target)
            require 'ruby2ruby'
            require 'parse_tree'
            require 'parse_tree_extensions'
          end
        end

        def value=(v)
          case v
            when Proc
              write_attribute(:value, v.to_ruby)
              write_attribute(:is_proc, true)
            else
              write_attribute(:value, v)
          end
        end
      end
    end
  end
end