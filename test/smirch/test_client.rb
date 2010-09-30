require 'helper'

class Smirch
  class TestClient < Test::Unit::TestCase
    def setup
      super
      @socket = stub('socket', :write => nil)
      TCPSocket.stubs(:new).returns(@socket)
      @client = Client.new('irc.freenode.net', 6667, 'smirch', 'smirch', 'Smirchy Guy')
    end

    def test_connect
      TCPSocket.expects(:new).with('irc.freenode.net', 6667).returns(@socket)
      seq = sequence("connection registration")
      @socket.expects(:write).with("NICK smirch\r\n").in_sequence(seq)
      @socket.expects(:write).with("USER smirch 0 * :Smirchy Guy\r\n")
      @client.connect
    end

    def test_poll_fills_queue
      @client.connect

      message = %{:gibson.freenode.net NOTICE * :*** Looking up your hostname...\r\n:gibson.freenode.net NOTICE * :*** Checking Ident\r\n:gibson.freenode.net NOTICE * :*** No Ident response\r\n:gibson.freenode.net NOTICE * :*** Couldn't look up your hostname\r\n}
      @socket.expects(:read_nonblock).with(512).returns(message)
      @client.poll
      assert_equal 4, @client.queue.length
      assert_equal ":gibson.freenode.net NOTICE * :*** Looking up your hostname...", @client.queue.shift
    end

    def test_poll_no_data
      @client.connect
      @socket.expects(:read_nonblock).with(512).raises(Errno::EAGAIN)
      @client.poll
    end

    def test_poll_lots_of_data
      @client.connect

      message = ""
      100.times { message << ":gibson.freenode.net NOTICE * :hey buddy\r\n" }
      num = (message.length / 512.0).ceil
      chunks = []
      num.times { |i| chunks << message[(i*512)..((i+1)*512-1)] }
      @socket.expects(:read_nonblock).with(512).times(num).returns(*chunks)
      @client.poll
      assert_equal 100, @client.queue.length
    end

    def test_ping
      @client.connect

      message = %{PING :gibson.freenode.net\r\n}
      @socket.expects(:read_nonblock).with(512).returns(message)
      @socket.expects(:write_nonblock).with("PONG\r\n")
      @client.poll
      assert @client.queue.empty?, @client.queue.inspect
    end

    def test_privmsg
      @client.connect
      @socket.expects(:write_nonblock).with("PRIVMSG dude :hey buddy\r\n")
      @client.privmsg('dude', 'hey buddy')
    end

    def test_execute
      @client.connect
      @socket.expects(:write_nonblock).with("FOO huge bar\r\n")
      @client.execute('foo', 'huge bar')
    end
  end
end
