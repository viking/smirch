require 'helper'

class UnitTests::TestBase < Test::Unit::TestCase
  def test_process
    app = stub('app')
    client = stub('client')
    root = IrcMessageParser.new.parse(":gibson.freenode.net NOTICE * :*** Looking up your hostname...")
    klass = Class.new(Smirch::IrcMessage::Base) { def setup(*args); @text = "foo bar baz"; end }
    message = klass.new(root)
    app.expects(:print).with(":gibson.freenode.net NOTICE * :*** Looking up your hostname...\n")
    message.process(app, client)
  end
end
