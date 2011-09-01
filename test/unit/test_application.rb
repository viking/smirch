require 'helper'

class UnitTests::TestApplication < Test::Unit::TestCase
  def setup
    @gui = stub('swt gui', :update => nil)
    Smirch::GUI::Swt.stubs(:new).returns(@gui)
    @client = stub('client', :connect => nil, :start_polling => nil, :queue => [])
    Smirch::IrcClient.stubs(:new).returns(@client)
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
end
