require 'helper'

class UnitTests::TestCTC < Test::Unit::TestCase
  def setup
    super
    @app = stub('app')
    @client = stub('client')
  end

  def test_process_when_channel
    data = %{:viking!~viking@example.com PRIVMSG #hugetown :hey buddy}
    message = Smirch::IrcMessage.parse(data)
    @app.expects(:print).with("<viking> hey buddy\n", '#hugetown')
    message.process(@app, @client)
  end

  def test_process_when_server
    data = %{:gibson.freenode.net NOTICE * :*** Looking up your hostname...}
    message = Smirch::IrcMessage.parse(data)
    @app.expects(:print).with("* *** Looking up your hostname...\n", "Server")
    message.process(@app, @client)
  end

  #def test_process_when_private
    #join = %{:not_me!~someone_else@example.com JOIN :#hugetown}
    #message = Smirch::IrcMessage.parse(join)
    #message.from.me = false

    #@app.expects(:print).with("* not_me (~someone_else@example.com) joined #hugetown\n", "#hugetown")
    #message.process(@app, @client)
  #end
end
