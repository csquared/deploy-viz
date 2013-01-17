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
    p data
=begin
    if data[:cloud] == "heroku.com" && data[:actor].include?("@heroku.com") && !data[:actor].include?("wolfpack")
      lat, long = Geocoder.coordinates(data[:source_ip])
      if lat.nil? || long.nil?
        puts "app=atlas error=true lat=#{lat} long=#{long} ip=#{data[:source_ip]}"
        return
      end

      actor = data[:actor]

      record = Atlas::DB[:locations].where(actor: actor).first
      if record
        Atlas::DB[:locations]
          .where(actor: actor)
          .update(longitude: long, latitude: lat)
      else
        Atlas::DB[:locations]
          .insert(latitude: lat,longitude: long, actor: actor)
      end
    end
=end
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
