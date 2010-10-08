module Smirch
  class IrcClient
    attr_reader :queue, :channels
    def initialize(host, port, nick, user, real)
      @host = host
      @port = port
      @nick = nick
      @user = user
      @real = real
      @channels = {}
      @queue = []
      @mutex = Mutex.new
    end

    def connect
      @socket = TCPSocket.new(@host, @port)
      @socket.write("NICK #{@nick}\r\n")
      @socket.write("USER #{@user} 0 * :#{@real}\r\n")
    end

    def start_polling
      @thread = Thread.new { poll; sleep 0.25 }
    end

    def stop_polling
      @thread.kill
      @thread = nil
    end

    def poll
      if @mutex.try_lock
        begin
          data = @socket.read_nonblock(512)
          loop do
            messages = data.split(/\r\n/, -1)
            remaining = messages.pop
            messages.each do |message|
              result = IrcMessage.parse(message)
              # FIXME: this if-condition can go away after parser bugs are fixed
              if result
                result.from.me = (result.from.nick == @nick)  if result.from
                result = post_process(result)
                @queue.push(result)   if result
              end
            end
            break if remaining.empty?
            data = remaining + @socket.read_nonblock(512)
          end
        rescue Errno::EAGAIN
          # no data
        ensure
          @mutex.unlock
        end
      end
    end

    def privmsg(user, message)
      @socket.write_nonblock("PRIVMSG #{user} :#{message}\r\n")
    end

    def execute(command, predicate)
      @socket.write_nonblock("#{command.upcase} #{predicate}\r\n")
    end

    private
      # FIXME: use hooks instead
      def post_process(message)
        channel = message.channel_name ? @channels[message.channel_name] : nil
        case message
        when IrcMessage::Ping
          @socket.write_nonblock("PONG\r\n")
          return nil
        when IrcMessage::Join
          if message.from.me?
            add_channel(message.channel_name)
          else
            channel.push(message.from.nick)
          end
        when IrcMessage::Part
          if message.from.me?
            delete_channel(message.channel_name)
          else
            channel.delete(message.from.nick)
          end
        when IrcMessage::Numeric
          case message.code
          when 353
            channel.push(*message.text.split(/\s+/))
          end
        end
        message
      end

      def add_channel(name)
        @channels[name] = Channel.new(name)
      end

      def delete_channel(name)
        @channels.delete(name)
      end
  end
end

require File.dirname(__FILE__) + "/irc_client/channel.rb"
