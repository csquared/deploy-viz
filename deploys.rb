require 'redis'
require 'uri'


if ENV['REDISTOGO_URL']
  uri = URI.parse(ENV['REDISTOGO_URL'])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  REDIS = Redis.new
end

class Deploys

  def self.redis
    @redis ||= REDIS
  end

  def self.add(app_name)
    redis.rpush('deploys', app_name)
  end

  def self.queue_length
    redis.llen('deploys')
  end

  def self.flush!(length = nil)
    length ||= queue_length
    Array.new(length.to_i) do
      redis.lpop('deploys')
    end.compact
  end
end
