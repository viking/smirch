require 'helper'

class Smirch
  class TestMessageParser < Test::Unit::TestCase
    def test_server_notice
      message = ":gibson.freenode.net NOTICE * :*** Looking up your hostname..."
      parser = MessageParser.new
      result = parser.parse(message)
      assert result, parser.failure_reason
    end

    def test_RPL_WELCOME
      message = %{:asimov.freenode.net 001 crookshanks :Welcome to the freenode Internet Relay Chat Network crookshanks}
      parser = MessageParser.new
      result = parser.parse(message)
      assert result, parser.failure_reason
      #p result.prefix_expression.prefix.text_value
    end
  end
end
