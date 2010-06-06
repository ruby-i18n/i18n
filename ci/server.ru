# example payload:
#
# {
#   "before": "533373f50625df607c9fed0092581b75abffb183",
#   "repository": { "url": "http://github.com/svenfuchs/i18n", "name": "i18n" },
#   "commits": [ { "id": "25456ac13e5995b4a4f68dcf13d5ce95b1a687a7" } ],
#   "after": "25456ac13e5995b4a4f68dcf13d5ce95b1a687a7",
#   "ref": "refs/heads/master"
# }
#
# curl -d payload=%7B%22before%22%3A%22533373f50625df607c9fed0092581b75abffb183%
# 22%2C%22repository%22%3A%7B%22url%22%3A%22http%3A%2F%2Fgithub.com%2Fsvenfuchs%
# 2Fi18n%22%2C%22name%22%3A%22i18n%22%7D%2C%22commits%22%3A%5B%7B%22id%22%3A%222
# 5456ac13e5995b4a4f68dcf13d5ce95b1a687a7%22%7D%5D%2C%22after%22%3A%2225456ac13e
# 5995b4a4f68dcf13d5ce95b1a687a7%22%2C%22ref%22%3A%22refs%2Fheads%2Fmaster%22%7D
# localhost:9292

require 'rubygems'
require 'sinatra'

require 'ci/controllers/server'
require 'ci/models/build'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3:///tmp/ci-i18n-development.db")
DataMapper.auto_upgrade!

targets = %w(
  http://ci-i18n-client-186.heroku.com
  http://ci-i18n-client-187.heroku.com
  http://ci-i18n-client-191.heroku.com
)

run Ci::Server.new('http://github.com/svenfuchs/i18n', targets)
