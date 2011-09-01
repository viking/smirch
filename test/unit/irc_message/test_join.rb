require 'helper'

class UnitTests::TestJoin < Test::Unit::TestCase
  def setup
    super
    @app = stub('app')
    @client = stub('client')
  end

  def test_process_when_self
    join = %{:smirch!~smirch@example.com JOIN :#hugetown}
    message = Smirch::IrcMessage.parse(join)
    message.from.me = true
    @app.expects(:new_tab).with("#hugetown")
    message.process(@app, @client)
  end

  def test_process_when_someone_else
    join = %{:not_me!~someone_else@example.com JOIN :#hugetown}
    message = Smirch::IrcMessage.parse(join)
    message.from.me = false

    @app.expects(:print).with("* not_me (~someone_else@example.com) joined #hugetown\n", "#hugetown")
    message.process(@app, @client)
  end
end
