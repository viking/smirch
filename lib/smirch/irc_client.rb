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
      @thread = Thread.new { loop { poll; sleep 0.25 } }
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
            raw_messages = data.split(/\r\n/, -1)
            remaining = raw_messages.pop
            raw_messages.each do |raw_message|
              message = IrcMessage.parse(raw_message)
              # FIXME: this if-condition can go away after parser bugs are fixed
              if message
                message.from.me = (message.from.nick == @nick)  if message.from
                @queue.push(message)
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

    def execute(command, predicate = nil)
      data = command.upcase
      data << " #{predicate}"   if predicate
      data << "\r\n"
      @socket.write_nonblock(data)
    end
  end
end

require File.dirname(__FILE__) + "/irc_client/channel"
