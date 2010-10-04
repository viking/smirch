require 'rubygems'
require 'test/unit'
require 'mocha'
require 'pp'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'smirch'

class Test::Unit::TestCase
end

class TestSmirch < Test::Unit::TestCase
  class TestIrcMessage < Test::Unit::TestCase
    def test_blah
      # silly autotest
    end
  end
  def test_blah
    # silly autotest
  end
end

class TCPSocket
  def new(*args)
    raise "Don't connect to the internet in tests, yo!"
  end
end
