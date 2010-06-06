require 'dm-core'

class Build
  include DataMapper::Resource
  property :id,         Serial
  property :target,     String
  property :commit,     String
  property :status,     Boolean
  property :output,     Text
  property :created_at, DateTime
end


