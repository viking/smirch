module Smirch
  class IrcClient
    attr_reader :queue, :channels, :nick

    def initialize(options)
      @options = options
      @channels = {}
      @queue = []
      @mutex = Mutex.new
      @nick = options['nick']
    end

    def connect(&block)
      if @options['proxy_host']
        host = TCPSocket::SOCKSConnectionPeerAddress.new(@options['proxy_host'], @options['proxy_port'], @options['server'])
      else
        host = @options['server']
      end
      @socket = TCPSocket.new(host, @options['port'])
      block.call if block
      connected
    end

    def connected
      @socket.write("NICK #{@nick}\r\n")
      @socket.write("USER #{@options['user']} 0 * :#{@options['real']}\r\n")
    end

    def start_polling
      @thread = Thread.new { loop { poll; sleep 0.25 } }
    end

    def stop_polling
      @thread.kill
      @thread = nil
    end

    def poll
      #print "Client polling..."
      if @mutex.try_lock
        begin
          data = @socket.read_nonblock(512)
          #puts data.inspect
          loop do
            raw_messages = data.split(/\r\n/, -1)
            remaining = raw_messages.pop
            raw_messages.each do |raw_message|
              message = IrcMessage.parse(raw_message)
              if message.from
                message.from.me = (message.from.nick == @nick)
              end

              ignore = false
              case message
              when nil
                # FIXME: this condition can go away after parser bugs are fixed
                puts "ZOMG: #{raw_message}"
                ignore = true
              when IrcMessage::Ping
                execute("PONG")
                ignore = true
              when IrcMessage::Nick
                if message.from.me?
                  @nick = message.text
                end
              end

              if !ignore
                @queue.push(message)
              end
            end
            break if remaining.empty?
            data = remaining + @socket.read_nonblock(512)
          end
        rescue Errno::EAGAIN
          # no data
          #puts "Nothing."
        ensure
          @mutex.unlock
        end
      end
    end

    def privmsg(user, message)
      @socket.write_nonblock("PRIVMSG #{user} :#{message}\r\n")
    end

    def execute(command, predicate = nil)
      data = command.upcase
      data << " #{predicate}"   if predicate
      data << "\r\n"
      @socket.write_nonblock(data)
    end
  end
end
