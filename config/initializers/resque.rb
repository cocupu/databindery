require 'resque/server'
require 'resque/status_server'

Resque.redis = "localhost:6379" # default localhost:6379
Resque::Plugins::Status::Hash.expire_in = (24 * 60 * 60) # 24hrs in seconds
