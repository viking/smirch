require 'helper'

class UnitTests::TestJoin < Test::Unit::TestCase
  test "to_s when I join a channel" do
    join = %{:smirch!~smirch@example.com JOIN :#hugetown}
    message = Smirch::IrcMessage.parse(join)
    message.from.me = true
    assert_equal "#hugetown", message.channel_name
    assert_equal "", message.to_s
  end

  test "to_s when someone else joined a channel" do
    join = %{:not_me!~someone_else@example.com JOIN :#hugetown}
    message = Smirch::IrcMessage.parse(join)
    message.from.me = false
    assert_equal "#hugetown", message.channel_name
    assert_equal "* not_me (~someone_else@example.com) joined #hugetown", message.to_s
  end
end
