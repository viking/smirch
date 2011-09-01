require 'java'
require 'socket'
require 'treetop'
require 'yaml'
require 'etc'
require 'swt'
require 'socksify'
require 'pathname'

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

path = Pathname.new(File.dirname(__FILE__))
require path + "irc_message_parser"
require path + "smirch" + "application"
require path + "smirch" + "entity"
require path + "smirch" + "irc_message"
require path + "smirch" + "irc_client"
require path + "smirch" + "gui"
