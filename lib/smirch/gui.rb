module Smirch
  module GUI
  end
end

path = Pathname.new(File.dirname(__FILE__)) + 'gui'
require path + 'swt'
require path + 'nick_colorizer'
