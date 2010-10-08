require 'rubygems'
gem 'test-unit'
require 'test/unit'
require 'mocha'
require 'pp'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'smirch'

class Test::Unit::TestCase
end

class TCPSocket
  def new(*args)
    raise "Don't connect to the internet in tests, yo!"
  end
end
