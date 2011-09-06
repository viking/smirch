require 'helper'

class UnitTests::TestChannel < Test::Unit::TestCase
  def setup
    super
    @channel = Smirch::Channel.new('#hugetown')
  end

  def test_name
    assert_equal '#hugetown', @channel.name
  end

  def test_push_normal_nick
    @channel.push('smirch')
    assert_equal ['smirch'], @channel.nicks
  end

  def test_push_opped_nick
    @channel.push('@smirch')
    assert_equal ['smirch'], @channel.nicks
  end

  def test_push_voiced_nick
    @channel.push('+smirch')
    assert_equal ['smirch'], @channel.nicks
  end

  def test_delete
    @channel.push(*%w{foo bar baz})
    @channel.delete('foo')
    assert_equal %w{bar baz}, @channel.nicks
  end
end
