require 'helper'

class TestSmirch
  class TestIrcMessage
    class TestBase < Test::Unit::TestCase
      def test_draw
        chat_box = stub('chat box')
        window = stub('window', :current_chat_box => chat_box)
        root = IrcMessageParser.new.parse(":gibson.freenode.net NOTICE * :*** Looking up your hostname...")
        klass = Class.new(Smirch::IrcMessage::Base) { def setup(*args); @text = "foo bar baz"; end }
        message = klass.new(root)
        chat_box.expects(:append).with("foo bar baz\n")
        message.draw(window)
      end
    end
  end
end
