require 'ci/heroku'

Heroku.server('i18n')
Heroku.each_stack { |stack| Heroku.client('i18n', stack) }
