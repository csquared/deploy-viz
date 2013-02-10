require 'redis'

class Deploys

  def self.redis
    @redis ||= Redis.new
  end

  def self.add(app_name)
    redis.rpush('deploys', app_name)
  end

  def self.flush!
    Array.new(redis.llen('deploys')) do
      redis.lpop('deploys')
    end
  end
end
