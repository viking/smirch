require 'java'
require 'socket'
require 'treetop'
require File.dirname(__FILE__) + "/swt.jar"

class Smirch
  import "org.eclipse.swt.SWT"
  import "org.eclipse.swt.events.KeyListener"
  import "org.eclipse.swt.graphics.Font"
  include_package "org.eclipse.swt.widgets"
  include_package "org.eclipse.swt.layout"

  class PollRunner
    include java.lang.Runnable

    def initialize(display, client)
      @display = display
      @client = client
    end

    def run
      @display.asyncExec { @client.poll }
      @display.timerExec(500, self)
    end
  end

  class ReceiveRunner
    include java.lang.Runnable

    def initialize(display, client, chat_box)
      @display = display
      @client = client
      @chat_box = chat_box
    end

    def run
      queue = @client.queue
      while !queue.empty?
        message = queue.shift
        p message
        @chat_box.append(message + "\n")
      end
      @display.timerExec(500, self)
    end
  end

  def initialize
    @display = Display.new
    @shell = Shell.new(@display)

    @menu = Menu.new(@shell, SWT::BAR)
    @shell.menu_bar = @menu
    file_item = MenuItem.new(@menu, SWT::CASCADE)
    file_item.text = "&File"
    sub_menu = Menu.new(@shell, SWT::DROP_DOWN)
    file_item.menu = sub_menu
    config_item = MenuItem.new(sub_menu, SWT::PUSH)
    config_item.text = "&Settings"
    config_item.add_listener(SWT::Selection) { |event| settings(event) }

    @grid_layout = GridLayout.new(1, true)
    @shell.layout = @grid_layout

    black = @display.system_color(SWT::COLOR_BLACK)
    white = @display.system_color(SWT::COLOR_WHITE)
    @chat_box = Text.new(@shell, SWT::BORDER | SWT::MULTI | SWT::V_SCROLL | SWT::READ_ONLY)
    @chat_box.layout_data = GridData.new(GridData::FILL, GridData::FILL, true, true)
    @chat_box.background = black
    @chat_box.foreground = white
    @chat_box.font = Font.new(@display, "DejaVu Sans Mono", 18, 0)

    @input_box = Text.new(@shell, SWT::BORDER)
    grid_data = GridData.new(GridData::FILL, GridData::FILL, true, false)
    grid_data.heightHint = 25
    @input_box.layout_data = grid_data
    @input_box.add_key_listener(KeyListener.impl { |name, event|
      if name == :keyPressed && event.character == SWT::CR
        input_received
      end
    })
    @input_box.font = Font.new(@display, "DejaVu Sans Mono", 15, 0)
    @input_box.set_focus
  end

  def main_loop
    @shell.open
    while (!@shell.disposed?) do
      @display.sleep   if !@display.read_and_dispatch
    end
    @display.dispose
  end

  def input_received
    input = @input_box.text
    @input_box.text = ""

    if input[0] == ?/
      command, predicate = input.split(/\s+/, 2)

      case command
      when "/server"
        args = predicate.split(/\s+/, 5)
        args[1] = args[1].to_i
        @client = Client.new(*args)
        @client.connect

        # start timers
        @display.timerExec(250, PollRunner.new(@display, @client))
        @display.timerExec(500, ReceiveRunner.new(@display, @client, @chat_box))
      when "/msg"
        args = predicate.split(/\s+/, 2)
        @client.privmsg(*args)
        @chat_box.append(">#{args[0]}< #{args[1]}\n")
      else
        @client.execute(command[1..-1], predicate)
      end
    end
  end

  def settings(event)
    dialog = Shell.new(@shell, SWT::DIALOG_TRIM | SWT::PRIMARY_MODAL)
    dialog.set_size(300, 300)
    layout = GridLayout.new(2, false)
    dialog.layout = layout

    server_label = Label.new(dialog, SWT::LEFT)
    server_label.text = "Server"
    server_input = Text.new(dialog, SWT::BORDER)
    server_input.layout_data = GridData.new(GridData::FILL, GridData::FILL, true, false)

    port_label = Label.new(dialog, SWT::LEFT)
    port_label.text = "Port"
    port_input = Text.new(dialog, SWT::BORDER)
    port_input.layout_data = GridData.new(GridData::FILL, GridData::FILL, true, false)

    nick_label = Label.new(dialog, SWT::LEFT)
    nick_label.text = "Nick"
    nick_input = Text.new(dialog, SWT::BORDER)
    nick_input.layout_data = GridData.new(GridData::FILL, GridData::FILL, true, false)

    user_label = Label.new(dialog, SWT::LEFT)
    user_label.text = "User"
    user_input = Text.new(dialog, SWT::BORDER)
    user_input.layout_data = GridData.new(GridData::FILL, GridData::FILL, true, false)

    real_label = Label.new(dialog, SWT::LEFT)
    real_label.text = "Real Name"
    real_input = Text.new(dialog, SWT::BORDER)
    real_input.layout_data = GridData.new(GridData::FILL, GridData::FILL, true, false)

    save_button = Button.new(dialog, SWT::PUSH)
    save_button.text = "Save"
    cancel_button = Button.new(dialog, SWT::PUSH)
    cancel_button.text = "Cancel"

    dialog.pack
    dialog.open
  end
end

require File.dirname(__FILE__) + "/smirch/message"
require File.dirname(__FILE__) + "/smirch/message_parser"
require File.dirname(__FILE__) + "/smirch/client"
