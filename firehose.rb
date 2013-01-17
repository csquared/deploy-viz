require "pusher-client"
require "yajl"

require_relative "firehose/connection"

class Firehose
  attr :channel

  def initialize(opts={})
    @parser = Yajl::Parser.new(symbolize_keys: true)
    @parser.on_parse_complete = method(:parsed)

    @channel    = opts[:channel]
    @connection = Firehose::Connection.new(self,
      key:    opts[:key],
      secret: opts[:secret])

    @connection.connect
  end

  def parsed(data)
    puts "app=atlas parsed=#{data.size}"
    if data[:action] == 'deploy-app'
      puts "DEPLOY: #{data[:target]}"
    end
  end

  def channels
    [channel]
  end

  def callback
    lambda do
      puts "app=atlas callback=start"
      @connection.socket[channel].bind("app") do |data|
        puts "app=atlas data=#{data.size}"
        @parser.parse(data)
      end
    end
  end
end
