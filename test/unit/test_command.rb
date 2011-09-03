require 'helper'

class UnitTests::TestCommand < Test::Unit::TestCase
  test "execute" do
    opts = { :args => %w{server port nick user real} }
    executed = false
    args = nil
    c = Smirch::Command.new('server', opts) do |*c_args|
      executed = true
      args = c_args
    end
    assert c.execute("irc.example.com 12345 dude dude dude guy")
    assert_equal true, executed
    assert_equal %w{irc.example.com 12345 dude dude dude\ guy}, args
  end

  test "execute with not enough args" do
    opts = { :args => %w{server port nick user real} }
    c = Smirch::Command.new('server', opts) { |*args| }
    assert_equal :syntax_error, c.execute("irc.example.com 12345")
  end

  test "syntax" do
    opts = { :args => %w{server port nick user real} }
    c = Smirch::Command.new('server', opts) { |*args| }
    assert_equal "/server <server> <port> <nick> <user> <real>", c.syntax
  end

  test "execute with no args" do
    executed = false
    args = nil
    c = Smirch::Command.new('connect') do
      executed = true
    end
    assert c.execute
    assert_equal true, executed
  end

  test "syntax with no args" do
    c = Smirch::Command.new('connect') { |*args| }
    assert_equal "/connect", c.syntax
  end
end
