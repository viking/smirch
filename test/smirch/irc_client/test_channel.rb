require 'helper'

class TestSmirch
  class TestChannel < Test::Unit::TestCase
    def setup
      super
      @channel = Smirch::IrcClient::Channel.new('#hugetown')
    end

    def test_name
      assert_equal '#hugetown', @channel.name
    end

    def test_push_normal_user
      @channel.push('smirch')
      assert_equal ['smirch'], @channel.users
    end

    def test_push_opped_user
      @channel.push('@smirch')
      assert_equal ['smirch'], @channel.users
    end

    def test_push_voiced_user
      @channel.push('+smirch')
      assert_equal ['smirch'], @channel.users
    end

    def test_delete
      @channel.push(*%w{foo bar baz})
      @channel.delete('foo')
      assert_equal %w{bar baz}, @channel.users
    end
  end
end
