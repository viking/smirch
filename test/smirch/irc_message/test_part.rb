require 'helper'

class TestSmirch
  class TestIrcMessage
    class TestPart < Test::Unit::TestCase
      def test_draw_when_self
        window = stub('window')
        part = %{:viking!~viking@example.com PART #hugetown}
        message = Smirch::IrcMessage.parse(part)
        message.from.me = true
        window.expects(:close_tab).with("#hugetown")
        message.draw(window)
      end

      def test_draw_when_someone_else
        window = stub('window')
        part = %{:not_me!~someone_else@example.com PART #hugetown}
        message = Smirch::IrcMessage.parse(part)
        message.from.me = false

        text = stub('text box')
        window.expects(:find_tab).with("#hugetown").returns({:text => text})
        text.expects(:append).with("* not_me (~someone_else@example.com) left #hugetown\n")
        message.draw(window)
      end
    end
  end
end
