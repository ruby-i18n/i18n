# for specifications see http://en.wikipedia.org/wiki/IETF_language_tag
#
# SimpleParser does not implement advanced usages such as grandfathered tags

require 'i18n/locale/tag/basic'
require 'i18n/locale/tag/rfc4646'

module I18n
  module Locale
    module Tag
      class << self
        def implementation
          @@implementation ||= Rfc4646
        end
  
        def implementation=(implementation)
          @@implementation = implementation
        end
  
        def tag(tag)
          implementation.tag(tag)
        end
      end
    end
  end
end
