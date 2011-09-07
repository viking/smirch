require 'helper'

class UnitTests::TestQuit < Test::Unit::TestCase
  test "to_s when someone quits" do
    quit = %{:not_me!~someone_else@example.com QUIT :Quit: zomg quitz}
    message = Smirch::IrcMessage.parse(quit)
    message.from.me = false

    assert_equal "* not_me (~someone_else@example.com) has quit (Quit: zomg quitz)", message.to_s
  end
end
