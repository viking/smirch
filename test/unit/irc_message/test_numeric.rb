require 'helper'

class UnitTests::TestNumeric < Test::Unit::TestCase
  def setup
    super
    @app = stub('app')
    @client = stub('client')
  end

  test "to_s" do
    data = %{:asimov.freenode.net 001 crookshanks :Welcome to the freenode Internet Relay Chat Network crookshanks}
    message = Smirch::IrcMessage.parse(data)
    assert_equal "* Welcome to the freenode Internet Relay Chat Network crookshanks", message.to_s
  end
end
