require 'helper'

class UnitTests::TestPart < Test::Unit::TestCase
  def setup
    super
    @app = stub('app')
    @client = stub('client')
  end

  test "to_s when I leave a channel" do
    part = %{:viking!~viking@example.com PART #hugetown}
    message = Smirch::IrcMessage.parse(part)
    message.from.me = true
    assert_equal "#hugetown", message.channel_name
    assert_equal "", message.to_s
  end

  test "to_s when someone else leaves a channel" do
    part = %{:not_me!~someone_else@example.com PART #hugetown}
    message = Smirch::IrcMessage.parse(part)
    message.from.me = false

    assert_equal "#hugetown", message.channel_name
    assert_equal "* not_me (~someone_else@example.com) left #hugetown", message.to_s
  end
end
