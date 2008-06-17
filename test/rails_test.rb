RAILS_PATH = 'vendor/rails'

$:.unshift "#{RAILS_PATH}/actionpack/lib",
           "#{RAILS_PATH}/actionpack/test",
           "#{RAILS_PATH}/activesupport/lib",
           "#{RAILS_PATH}/activesupport/test",
           "#{RAILS_PATH}/activerecord", 
           "#{RAILS_PATH}/activerecord/lib", 
           "#{RAILS_PATH}/activerecord/test", 
           "#{RAILS_PATH}/activerecord/test/connections/native_sqlite3",
           "lib/i18n/lib"

require 'active_record'
require 'active_support'
require 'action_view/helpers/form_options_helper'

# require the library
require 'i18n'
require 'i18n/backend/simple'
I18n.backend = I18n::Backend::Simple
require 'i18n/backend/translations'

# require the patches
require 'patch/date_helper'
require 'patch/active_support'
require 'patch/form_options_helper'
require 'patch/active_record_helper'
require 'patch/number_helper'
require 'patch/active_record_validations'

# run the tests
require 'template/date_helper_test'
require 'core_ext/array_ext_test'
require 'template/form_options_helper_test'
require 'template/active_record_helper_test'
require 'template/number_helper_test'
require 'test/cases/validations_test'


