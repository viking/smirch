require 'helper'

class UnitTests::TestIrcClient < Test::Unit::TestCase
  def simulate_received(client, message)
    @socket.expects(:read_nonblock).returns(message)
    client.poll
  end

  def stub_message(name)
    stub(name, :from => stub_everything('entity'), :channel_name => nil)
  end

  def new_client(options = {})
    Smirch::IrcClient.new({
      'server' => 'irc.freenode.net',
      'port' => 6667,
      'nick' => 'smirch',
      'user' => 'smirch',
      'real' => 'Smirchy Guy'
    }.merge(options))
  end

  def setup
    super
    @socket = stub('socket', :write => nil)
    TCPSocket.stubs(:new).returns(@socket)
    Thread.stubs(:new).yields
  end

  def test_connect
    TCPSocket.expects(:new).with('irc.freenode.net', 6667).returns(@socket)
    seq = sequence("connection registration")
    @socket.expects(:write).with("NICK smirch\r\n").in_sequence(seq)
    @socket.expects(:write).with("USER smirch 0 * :Smirchy Guy\r\n")

    client = new_client
    client.connect
    assert client.connected?
  end

  def test_connect_with_proxy
    client = new_client('proxy_host' => 'localhost', 'proxy_port' => 12345)

    peer_address = stub('peer address')
    TCPSocket::SOCKSConnectionPeerAddress.expects(:new).with('localhost', 12345, 'irc.freenode.net').returns(peer_address)
    TCPSocket.expects(:new).with(peer_address, 6667).returns(@socket)
    client.connect
  end

  def test_connect_yield_when_connected
    ran = false
    new_client.connect { ran = true }
    assert ran
  end

  def test_poll_fills_queue
    messages = Array.new(4) { |i| stub_message("irc message #{i}") }
    data = [%{:gibson.freenode.net NOTICE * :*** Looking up your hostname...}, %{:gibson.freenode.net NOTICE * :*** Checking Ident}, %{:gibson.freenode.net NOTICE * :*** No Ident response}, %{:gibson.freenode.net NOTICE * :*** Couldn't look up your hostname}, ""]
    @socket.expects(:read_nonblock).with(512).returns(data.join("\r\n"))
    4.times { |i| Smirch::IrcMessage.expects(:parse).with(data[i]).returns(messages[i]) }

    client = new_client
    client.connect
    assert client.poll
    assert_equal messages, client.queue
  end

  def test_poll_no_data
    client = new_client
    client.connect
    @socket.expects(:read_nonblock).with(512).raises(Errno::EAGAIN)
    assert client.poll
  end

  def test_poll_lots_of_data
    client = new_client
    client.connect

    Smirch::IrcMessage.stubs(:parse).returns(stub_message('message'))
    message = ""
    100.times { message << ":gibson.freenode.net NOTICE * :hey buddy\r\n" }
    num = (message.length / 512.0).ceil
    chunks = []
    num.times { |i| chunks << message[(i*512)..((i+1)*512-1)] }
    @socket.expects(:read_nonblock).with(512).times(num).returns(*chunks)
    assert client.poll
    assert_equal 100, client.queue.length
  end

  def test_poll_when_disconnected
    client = new_client
    client.connect
    @socket.expects(:read_nonblock).with(512).raises(EOFError)
    assert !client.poll
    assert !client.connected?
  end

  def test_ping
    client = new_client
    client.connect

    message = %{PING :gibson.freenode.net\r\n}
    @socket.expects(:read_nonblock).with(512).returns(message)
    @socket.expects(:write_nonblock).with("PONG\r\n")
    client.poll
    assert client.queue.empty?, client.queue.inspect
  end

  def test_privmsg
    client = new_client
    client.connect
    @socket.expects(:write_nonblock).with("PRIVMSG dude :hey buddy\r\n")
    client.privmsg('dude', 'hey buddy')
  end

  def test_execute
    client = new_client
    client.connect
    @socket.expects(:write_nonblock).with("FOO huge bar\r\n")
    client.execute('foo', 'huge bar')
  end

  def test_me?
    client = new_client
    client.connect

    simulate_received(client, %{:asimov.freenode.net 001 smirch :Welcome to the freenode Internet Relay Chat Network smirch\r\n})
    simulate_received(client, %{:smirch!~smirch@example.com JOIN :#hugetown\r\n})

    message_1, message_2 = client.queue
    assert message_2.from.me?
  end

  test "tracks nick changes correctly" do
    client = new_client
    client.connect

    simulate_received(client, %{:smirch!~smirch@example.com JOIN :#hugetown\r\n})
    message = client.queue.shift
    assert_equal 'smirch', message.from.nick
    assert message.from.me?

    simulate_received(client, %{:smirch!~smirch@example.com NICK :monkeypants\r\n})
    message = client.queue.shift
    assert_equal 'smirch', message.from.nick
    assert message.from.me?

    simulate_received(client, %{:monkeypants!~smirch@example.com JOIN :#pantstown\r\n})
    message = client.queue.shift
    assert_equal 'monkeypants', message.from.nick
    assert message.from.me?
  end
end
