require 'java'
require 'socket'
require 'treetop'
require 'yaml'
require 'etc'
require 'swt'
require 'socksify'

module Smirch
  def self.load_config
    path = File.join(Etc.getpwuid.dir, '.smirchrc')
    File.exist?(path) ? YAML.load_file(path) : nil
  end

  def self.save_config(hash)
    File.open(File.join(Etc.getpwuid.dir, '.smirchrc'), 'w') { |f| f.write(hash.to_yaml) }
  end
end

Socksify.debug = true
Thread.abort_on_exception = true

require File.dirname(__FILE__) + "/irc_message_parser"
require File.dirname(__FILE__) + "/smirch/application"
require File.dirname(__FILE__) + "/smirch/entity"
require File.dirname(__FILE__) + "/smirch/irc_message"
require File.dirname(__FILE__) + "/smirch/irc_client"
