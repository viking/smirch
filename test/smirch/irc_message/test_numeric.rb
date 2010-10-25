require 'helper'

class TestSmirch
  class TestIrcMessage
    class TestNumeric < Test::Unit::TestCase
      def setup
        super
        @app = stub('app')
        @client = stub('client')
      end

      def test_process_prints_to_server_tab
        data = %{:asimov.freenode.net 001 crookshanks :Welcome to the freenode Internet Relay Chat Network crookshanks}
        message = Smirch::IrcMessage.parse(data)
        @app.expects(:print).with("* Welcome to the freenode Internet Relay Chat Network crookshanks\n", "Server")
        message.process(@app, @client)
      end
    end
  end
end
