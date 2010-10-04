require 'java'
require 'socket'
require 'treetop'
require File.dirname(__FILE__) + "/swt.jar"

module Smirch
  import "org.eclipse.swt.SWT"

  module Events
    import "org.eclipse.swt.events.KeyListener"
  end

  module Graphics
    import "org.eclipse.swt.graphics.Font"
  end

  module Widgets
    include_package "org.eclipse.swt.widgets"
  end

  module Layout
    include_package "org.eclipse.swt.layout"
  end
end

require File.dirname(__FILE__) + "/irc_message_parser"
require File.dirname(__FILE__) + "/smirch/main_window"
require File.dirname(__FILE__) + "/smirch/settings_dialog"
require File.dirname(__FILE__) + "/smirch/irc_message"
require File.dirname(__FILE__) + "/smirch/irc_client"
