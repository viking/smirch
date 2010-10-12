require 'helper'

class TestSmirch
  class TestIrcMessage
    class TestPing < Test::Unit::TestCase
      def test_before_process
        data = %{PING :irc.example.com}
        message = Smirch::IrcMessage.parse(data)

        app = stub('app')
        client = stub('client')
        client.expects(:execute).with("PONG")
        message.process(app, client)
      end
    end
  end
end
