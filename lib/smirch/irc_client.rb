module Smirch
  class IrcClient
    attr_reader :queue
    def initialize(host, port, nick, user, real)
      @host = host
      @port = port
      @nick = nick
      @user = user
      @real = real
      @queue = []
      @mutex = Mutex.new
    end

    def connect
      @socket = TCPSocket.new(@host, @port)
      @socket.write("NICK #{@nick}\r\n")
      @socket.write("USER #{@user} 0 * :#{@real}\r\n")
    end

    def poll
      if @mutex.try_lock
        begin
          data = @socket.read_nonblock(512)
          loop do
            messages = data.split(/\r\n/, -1)
            remaining = messages.pop
            messages.each do |message|
              if message =~ /^PING/
                @socket.write_nonblock("PONG\r\n")
              else
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

    def execute(command, predicate)
      @socket.write_nonblock("#{command.upcase} #{predicate}\r\n")
    end
  end
end
