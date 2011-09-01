require 'helper'

class UnitTests::TestBase < Test::Unit::TestCase
  test "to_s" do
    root = IrcMessageParser.new.parse(":gibson.freenode.net NOTICE * :*** Looking up your hostname...")
    klass = Class.new(Smirch::IrcMessage::Base) { def setup(*args); @text = "foo bar baz"; end }
    message = klass.new(root)
    expected = ":gibson.freenode.net NOTICE * :*** Looking up your hostname..."
    assert_equal expected, message.to_s
  end
end
