require 'helper'

class TestSmirch
  class TestIrcMessage
    class TestBase < Test::Unit::TestCase
      def test_process
        chat_box = stub('chat box')
        app = stub('app', :current_chat_box => chat_box)
        root = IrcMessageParser.new.parse(":gibson.freenode.net NOTICE * :*** Looking up your hostname...")
        klass = Class.new(Smirch::IrcMessage::Base) { def setup(*args); @text = "foo bar baz"; end }
        message = klass.new(root)
        chat_box.expects(:append).with("foo bar baz\n")
        message.process(app)
      end
    end
  end
end
