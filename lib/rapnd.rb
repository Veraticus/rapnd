require 'rapnd/daemon'
require 'rapnd/notification'
require 'rapnd/config'
require 'redis'

module Rapnd
  extend self
  
  def queue(queue_name, message)
    self.redis.lpush(queue_name, message.to_json)
  end
  
  def redis
    @redis ||= Redis.new(:host => Rapnd.config.redis_host, :port => Rapnd.config.redis_port, :password => Rapnd.config.redis_password)
  end
  
  def configure
    block_given? ? yield(Config) : Config
  end
  alias :config :configure

end