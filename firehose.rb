require "pusher-client"
require "yajl"

require_relative "firehose/connection"

class Firehose
  attr :channel

  def initialize(opts={}, &block)
    @parser = Yajl::Parser.new(symbolize_keys: true)
    @parser.on_parse_complete = method(:json_parsed)

    @channel    = opts[:channel]
    @connection = Firehose::Connection.new(self,
      key:    opts[:key],
      secret: opts[:secret])

    @callback = block if block_given?
    @connection.connect
  end

  def on_json(&block)
    @callback = block if block_given?
    @connection.connect
  end

  def json_parsed(data)
    puts "json_parsed=#{data.size}"
    if @callback
      puts "json_callback=true"
      @callback.call(data)
    else
      puts "json_callback=false"
    end
  end

  def channels
    [channel]
  end

  def callback
    lambda do
      puts "callback=start"
      @connection.socket[channel].bind("app") do |data|
        puts "data=#{data.size}"
        @parser.parse(data)
      end
    end
  end
end
