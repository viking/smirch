require 'helper'

class UnitTests::TestApplication < Test::Unit::TestCase
  def setup
    @gui = stub('swt gui', :update => nil)
    Smirch::GUI::Swt.stubs(:new).returns(@gui)
    @client = stub('client', :connect => nil, :start_polling => nil, :queue => [], :connected? => true)
    Smirch::IrcClient.stubs(:new).returns(@client)
  end

  def simulate_received(app, message)
    @client.stubs(:queue).returns([message])
    app.send(:check_client_for_messages)
  end

  test "initialize" do
    Smirch::GUI::Swt.expects(:new).with(kind_of(Smirch::Application), "Smirch").returns(@gui)
    s = Smirch::Application.new
  end

  test "main_loop" do
    s = Smirch::Application.new
    @gui.expects(:main_loop)
    s.main_loop
  end

  test "/server" do
    s = Smirch::Application.new

    seq = sequence("/server")
    @gui.expects(:update).with(:client_connecting).in_sequence(seq)
    Smirch::IrcClient.expects(:new).with({
      'server' => 'irc.example.com', 
      'port' => 6666,
      'nick' => 'MyNick',
      'user' => 'MyUser',
      'real' => 'Dude guy'
    }).returns(@client).in_sequence(seq)

    Thread.expects(:new).yields.in_sequence(seq)
    @client.expects(:connect).yields.in_sequence(seq)
    @gui.expects(:update).with(:client_connected).in_sequence(seq)
    @client.expects(:start_polling).in_sequence(seq)

    # periodic thread to do grab messages from the client
    Thread.expects(:new).in_sequence(seq)

    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")
  end

  test "/msg" do
    s = Smirch::Application.new
    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")
    @client.expects(:privmsg).with('dude', 'hey')
    @gui.expects(:update).with(:privmsg, "dude", "hey")
    s.execute("/msg dude hey")
  end

  test "/msg requires connection" do
    s = Smirch::Application.new
    @gui.expects(:update).with(:connection_required)
    s.execute("/msg dude hey")
  end

  test "/msg fails if client was disconnected" do
    s = Smirch::Application.new
    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")
    @client.expects(:connected?).returns(false)
    @gui.expects(:update).with(:connection_required)
    s.execute("/msg dude hey")
  end

  test "unknown command" do
    s = Smirch::Application.new
    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")
    @client.expects(:execute).with('foo', 'huge bar')
    s.execute("/foo huge bar")
  end

  test "unknown command requires connection" do
    s = Smirch::Application.new
    @gui.expects(:update).with(:connection_required)
    s.execute("/foo huge bar")
  end

  test "/connect" do
    config = {'server' => 'irc.example.com', 'port' => 6666, 'nick' => 'MyNick', 'user' => 'MyUser', 'real' => 'Dude guy'}
    Smirch.expects(:load_config).returns(config)
    s = Smirch::Application.new

    seq = sequence("/connect")
    @gui.expects(:update).with(:client_connecting).in_sequence(seq)
    Smirch::IrcClient.expects(:new).with({
      'server' => 'irc.example.com', 
      'port' => 6666,
      'nick' => 'MyNick',
      'user' => 'MyUser',
      'real' => 'Dude guy'
    }).returns(@client).in_sequence(seq)

    Thread.expects(:new).yields.in_sequence(seq)
    @client.expects(:connect).yields.in_sequence(seq)
    @gui.expects(:update).with(:client_connected).in_sequence(seq)
    @client.expects(:start_polling).in_sequence(seq)

    # periodic thread to do grab messages from the client
    Thread.expects(:new).in_sequence(seq)

    s.execute("/connect")
  end

  test "nick" do
    s = Smirch::Application.new
    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")
    @client.expects(:nick).returns("MyNick")
    assert_equal "MyNick", s.nick
  end

  test "syntax error" do
    s = Smirch::Application.new
    @gui.expects(:update).with(:syntax_error, "/connect")
    s.execute("/connect foo bar")
  end

  test "client message updates gui" do
    s = Smirch::Application.new
    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")
    message = stub('message')
    @gui.expects(:update).with(:message_received, message)
    simulate_received(s, message)
  end

  test "joining/parting a channel creates/deletes channel" do
    s = Smirch::Application.new
    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")
    assert_empty s.channels

    message = Smirch::IrcMessage::Join.allocate
    message.stubs(:from => stub(:me? => true), :channel_name => '#foo')
    Smirch::Channel.expects(:new).with("#foo").returns(stub('channel'))
    simulate_received(s, message)
    assert_not_empty s.channels

    message = Smirch::IrcMessage::Part.allocate
    message.stubs(:from => stub(:me? => true), :channel_name => '#foo')
    simulate_received(s, message)
    assert_empty s.channels
  end

  test "receiving names for a channel updates channel" do
    s = Smirch::Application.new
    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")

    # join channel
    message = Smirch::IrcMessage::Join.allocate
    message.stubs(:from => stub(:me? => true), :channel_name => '#foo')
    channel = mock('channel')
    Smirch::Channel.expects(:new).with("#foo").returns(channel)
    simulate_received(s, message)

    # get names
    message = Smirch::IrcMessage::Names.allocate
    message.stubs(:channel_name => '#foo', :nicks => %w{foo bar baz})
    channel.expects(:push).with('foo', 'bar', 'baz')
    simulate_received(s, message)
  end

  test "do nothing when receiving names for a channel that I'm not on" do
    s = Smirch::Application.new
    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")
    message = Smirch::IrcMessage::Names.allocate
    message.stubs(:channel_name => '#foo', :nicks => %w{foo bar baz})
    simulate_received(s, message)
  end

  test "add nick to channel when someone joins" do
    s = Smirch::Application.new
    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")

    # join channel
    message = Smirch::IrcMessage::Join.allocate
    message.stubs(:from => stub(:me? => true), :channel_name => '#foo')
    channel = mock('channel')
    Smirch::Channel.expects(:new).with("#foo").returns(channel)
    simulate_received(s, message)

    # someone else joins
    message = Smirch::IrcMessage::Join.allocate
    message.stubs(:from => stub(:me? => false, :nick => 'dude'), :channel_name => '#foo')
    channel.expects(:push).with('dude')
    simulate_received(s, message)
  end

  test "remove nick from channel when someone leaves" do
    s = Smirch::Application.new
    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")

    # join channel
    message = Smirch::IrcMessage::Join.allocate
    message.stubs(:from => stub(:me? => true), :channel_name => '#foo')
    channel = mock('channel')
    Smirch::Channel.expects(:new).with("#foo").returns(channel)
    simulate_received(s, message)

    # someone else leaves
    message = Smirch::IrcMessage::Part.allocate
    message.stubs(:from => stub(:me? => false, :nick => 'dude'), :channel_name => '#foo')
    channel.expects(:delete).with('dude')
    simulate_received(s, message)
  end

  test "remove nick from all channels when someone disconnects" do
    s = Smirch::Application.new
    s.execute("/server irc.example.com 6666 MyNick MyUser Dude guy")

    # join channel
    message = Smirch::IrcMessage::Join.allocate
    message.stubs(:from => stub(:me? => true), :channel_name => '#foo')
    channel_1 = mock('channel')
    Smirch::Channel.expects(:new).with("#foo").returns(channel_1)
    simulate_received(s, message)

    # join another channel
    message = Smirch::IrcMessage::Join.allocate
    message.stubs(:from => stub(:me? => true), :channel_name => '#bar')
    channel_2 = mock('channel')
    Smirch::Channel.expects(:new).with("#bar").returns(channel_2)
    simulate_received(s, message)

    # someone else quits
    message = Smirch::IrcMessage::Quit.allocate
    message.stubs(:from => stub(:me? => false, :nick => 'dude'))
    channel_1.expects(:delete).with('dude')
    channel_2.expects(:delete).with('dude')
    simulate_received(s, message)
  end
end
