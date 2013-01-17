class Firehose
  class Connection
    attr_reader :source

    def initialize(source, opts={})
      @key    = opts[:key]
      @secret = opts[:secret]
      @source = source
    end

    # Pusher configuration options
    def options
      { encrypted: true,
        secret: @secret }
    end

    def connect
      subscribe_to_channels
      set_callbacks
      connect_socket
    end

    # Return a Pusher socket to our stream
    def socket
      @socket ||= PusherClient::Socket.new(@key, options)
    end

    # Subscribe to all channels defined on the source
    def subscribe_to_channels
      channels.each do |channel|
        socket.subscribe(channel)
      end
    end

    # Returns the channels a given source provides
    def channels
      source.channels
    end

    # Bind to the events that source provides
    def set_callbacks
      source.callback.call
    end

    # Open the connection on the Pusher socket
    def connect_socket
      socket.connect
    end
  end
end
