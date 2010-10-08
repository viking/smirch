require 'helper'

class TestSmirch
  class TestIrcMessage
    class TestPart < Test::Unit::TestCase
      def test_process_when_self
        app = stub('app')
        part = %{:viking!~viking@example.com PART #hugetown}
        message = Smirch::IrcMessage.parse(part)
        message.from.me = true
        app.expects(:close_tab).with("#hugetown")
        message.process(app)
      end

      def test_process_when_someone_else
        app = stub('app')
        part = %{:not_me!~someone_else@example.com PART #hugetown}
        message = Smirch::IrcMessage.parse(part)
        message.from.me = false

        text = stub('text box')
        app.expects(:find_tab).with("#hugetown").returns({:text => text})
        text.expects(:append).with("* not_me (~someone_else@example.com) left #hugetown\n")
        message.process(app)
      end
    end
  end
end
