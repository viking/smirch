require 'helper'

class TestSmirch
  class TestIrcClient < Test::Unit::TestCase
    def setup
      super
      @socket = stub('socket', :write => nil)
      TCPSocket.stubs(:new).returns(@socket)
      #@channel = stub('channel')
      #Smirch::IrcClient::Channel.stubs(:new).returns(@channel)
      @client = Smirch::IrcClient.new('irc.freenode.net', 6667, 'smirch', 'smirch', 'Smirchy Guy')
    end

    def test_connect
      TCPSocket.expects(:new).with('irc.freenode.net', 6667).returns(@socket)
      seq = sequence("connection registration")
      @socket.expects(:write).with("NICK smirch\r\n").in_sequence(seq)
      @socket.expects(:write).with("USER smirch 0 * :Smirchy Guy\r\n")
      @client.connect
    end

    def test_poll_fills_queue
      messages = Array.new(4) { |i| stub("irc message #{i}", :from => stub_everything('entity')) }
      data = [%{:gibson.freenode.net NOTICE * :*** Looking up your hostname...}, %{:gibson.freenode.net NOTICE * :*** Checking Ident}, %{:gibson.freenode.net NOTICE * :*** No Ident response}, %{:gibson.freenode.net NOTICE * :*** Couldn't look up your hostname}, ""]
      @socket.expects(:read_nonblock).with(512).returns(data.join("\r\n"))
      4.times { |i| Smirch::IrcMessage.expects(:parse).with(data[i]).returns(messages[i]) }

      @client.connect
      @client.poll
      assert_equal messages, @client.queue
    end

    def test_poll_no_data
      @client.connect
      @socket.expects(:read_nonblock).with(512).raises(Errno::EAGAIN)
      @client.poll
    end

    def test_poll_lots_of_data
      @client.connect

      Smirch::IrcMessage.stubs(:parse).returns(stub('message', :from => stub_everything('entity')))
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

    def test_me?
      @client.connect

      rpl_welcome = %{:asimov.freenode.net 001 smirch :Welcome to the freenode Internet Relay Chat Network smirch\r\n}
      @socket.expects(:read_nonblock).returns(rpl_welcome)
      @client.poll

      join = %{:smirch!~smirch@example.com JOIN :#hugetown\r\n}
      @socket.expects(:read_nonblock).returns(join)
      @client.poll

      message_1, message_2 = @client.queue
      assert message_2.from.me?
    end

    def test_join_starts_tracking_channels
      @client.connect

      channel = stub('channel')
      Smirch::IrcClient::Channel.expects(:new).with('#hugetown').returns(channel)

      join = %{:smirch!~smirch@example.com JOIN :#hugetown\r\n}
      @socket.expects(:read_nonblock).returns(join)
      @client.poll

      assert_equal channel, @client.channels['#hugetown']
    end
  end
end
