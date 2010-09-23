class Smirch
  class Client
    attr_reader :queue
    def initialize(host, port, opts = {})
      @host = host
      @port = port
      @options = opts
      @queue = []
      @mutex = Mutex.new
    end

    def connect
      @socket = TCPSocket.new(@host, @port)
    end

    def poll
      if @mutex.try_lock
        begin
          data = @socket.read_nonblock(512)
          loop do
            messages = data.split(/\r\n/, -1)
            p messages
            remaining = messages.pop
            @queue.push(*messages)
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
  end
end
