require 'helper'

class Smirch
  class TestClient < Test::Unit::TestCase
    def setup
      super
      @socket = stub('socket')
      TCPSocket.stubs(:new).returns(@socket)
      @options = { :nick => 'smirch', :user => 'smirch', :real => 'Smirchy' }
    end

    def test_connect
      client = Client.new('irc.freenode.net', 6667, @options)
      TCPSocket.expects(:new).with('irc.freenode.net', 6667).returns(@socket)
      client.connect
    end

    def test_poll_fills_queue
      client = Client.new('irc.freenode.net', 6667, @options)
      client.connect

      message = %{:gibson.freenode.net NOTICE * :*** Looking up your hostname...\r\n:gibson.freenode.net NOTICE * :*** Checking Ident\r\n:gibson.freenode.net NOTICE * :*** No Ident response\r\n:gibson.freenode.net NOTICE * :*** Couldn't look up your hostname\r\n}
      @socket.expects(:read_nonblock).with(512).returns(message)
      client.poll
      assert_equal 4, client.queue.length
      assert_equal ":gibson.freenode.net NOTICE * :*** Looking up your hostname...", client.queue.shift
    end

    def test_poll_no_data
      client = Client.new('irc.freenode.net', 6667, @options)
      client.connect
      @socket.expects(:read_nonblock).with(512).raises(Errno::EAGAIN)
      client.poll
    end

    def test_poll_lots_of_data
      client = Client.new('irc.freenode.net', 6667, @options)
      client.connect

      message = ""
      100.times { message << ":gibson.freenode.net NOTICE * :hey buddy\r\n" }
      num = (message.length / 512.0).ceil
      chunks = []
      num.times { |i| chunks << message[(i*512)..((i+1)*512-1)] }
      @socket.expects(:read_nonblock).with(512).times(num).returns(*chunks)
      client.poll
      assert_equal 100, client.queue.length
    end
  end
end
