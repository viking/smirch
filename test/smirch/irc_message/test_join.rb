require 'helper'

class TestSmirch
  class TestIrcMessage
    class TestJoin < Test::Unit::TestCase
      def test_draw_when_self
        window = stub('window')
        join = %{:smirch!~smirch@example.com JOIN :#hugetown}
        message = Smirch::IrcMessage.parse(join)
        message.from.me = true
        window.expects(:new_tab).with("#hugetown")
        message.draw(window)
      end

      def test_draw_when_someone_else
        window = stub('window')
        join = %{:not_me!~someone_else@example.com JOIN :#hugetown}
        message = Smirch::IrcMessage.parse(join)
        message.from.me = false

        text = stub('text box')
        window.expects(:find_tab).with("#hugetown").returns({:text => text})
        text.expects(:append).with("* not_me (~someone_else@example.com) joined #hugetown\n")
        message.draw(window)
      end
    end
  end
end
