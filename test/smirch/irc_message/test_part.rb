require 'helper'

class TestSmirch
  class TestIrcMessage
    class TestPart < Test::Unit::TestCase
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

        text = stub('text box')
        @app.expects(:find_tab).with("#hugetown").returns({:text => text})
        text.expects(:append).with("* not_me (~someone_else@example.com) left #hugetown\n")
        message.process(@app, @client)
      end
    end
  end
end
