require 'helper'

class UnitTests::TestPart < Test::Unit::TestCase
  def setup
    super
    @app = stub('app')
    @client = stub('client')
  end

  def test_process_when_self
    part = %{:viking!~viking@example.com PART #hugetown}
    message = Smirch::IrcMessage.parse(part)
    message.from.me = true
    @app.expects(:close_tab).with("#hugetown")
    message.process(@app, @client)
  end

  def test_process_when_someone_else
    part = %{:not_me!~someone_else@example.com PART #hugetown}
    message = Smirch::IrcMessage.parse(part)
    message.from.me = false

    @app.expects(:print).with("* not_me (~someone_else@example.com) left #hugetown\n", '#hugetown')
    message.process(@app, @client)
  end
end
