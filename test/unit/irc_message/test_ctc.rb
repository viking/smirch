require 'helper'

class UnitTests::TestCTC < Test::Unit::TestCase
  test "to_s when channel msg" do
    data = %{:viking!~viking@example.com PRIVMSG #hugetown :hey buddy}
    message = Smirch::IrcMessage.parse(data)
    assert_equal "#hugetown", message.channel_name
    assert_equal "<viking> hey buddy", message.to_s
  end

  test "to_s when server notice" do
    data = %{:gibson.freenode.net NOTICE * :*** Looking up your hostname...}
    message = Smirch::IrcMessage.parse(data)
    assert_equal "* *** Looking up your hostname...", message.to_s
  end
end
