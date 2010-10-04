module Smirch
  class MainWindow
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

      def initialize(display, client, parent)
        @display = display
        @client = client
        @parent = parent
      end

      def run
        queue = @client.queue
        while !queue.empty?
          message = queue.shift
          message.draw(@parent)
        end
        @display.timerExec(500, self)
      end
    end

    attr_reader :chat_box

    def initialize
      @display = Widgets::Display.new
      @shell = Widgets::Shell.new(@display)

      menu = Widgets::Menu.new(@shell, SWT::BAR)
      @shell.menu_bar = menu
      file_item = Widgets::MenuItem.new(menu, SWT::CASCADE)
      file_item.text = "&File"
      sub_menu = Widgets::Menu.new(@shell, SWT::DROP_DOWN)
      file_item.menu = sub_menu
      config_item = Widgets::MenuItem.new(sub_menu, SWT::PUSH)
      config_item.text = "&Settings"
      config_item.add_listener(SWT::Selection) { |e| SettingsDialog.new(@shell, e) }
      quit_item = Widgets::MenuItem.new(sub_menu, SWT::PUSH)
      quit_item.text = "&Quit"
      quit_item.add_listener(SWT::Selection) { |e| @shell.close }

      @grid_layout = Layout::GridLayout.new(1, true)
      @shell.layout = @grid_layout

      black = @display.system_color(SWT::COLOR_BLACK)
      white = @display.system_color(SWT::COLOR_WHITE)
      @chat_box = Widgets::Text.new(@shell, SWT::BORDER | SWT::MULTI | SWT::V_SCROLL | SWT::READ_ONLY)
      @chat_box.layout_data = Layout::GridData.new(Layout::GridData::FILL, Layout::GridData::FILL, true, true)
      @chat_box.background = black
      @chat_box.foreground = white
      @chat_box.font = Graphics::Font.new(@display, "DejaVu Sans Mono", 18, 0)

      @input_box = Widgets::Text.new(@shell, SWT::BORDER)
      grid_data = Layout::GridData.new(Layout::GridData::FILL, Layout::GridData::FILL, true, false)
      grid_data.heightHint = 25
      @input_box.layout_data = grid_data
      @input_box.add_key_listener(Events::KeyListener.impl { |name, event|
        if name == :keyPressed && event.character == SWT::CR
          input_received
        end
      })
      @input_box.font = Graphics::Font.new(@display, "DejaVu Sans Mono", 15, 0)
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
        when "/connect"
          config = Smirch.load_config
          setup_client(config.values_at('server', 'port', 'nick', 'user', 'real'))
        when "/server"
          args = predicate.split(/\s+/, 5)
          args[1] = args[1].to_i
          setup_client(args)
        when "/msg"
          args = predicate.split(/\s+/, 2)
          @client.privmsg(*args)
          @chat_box.append(">#{args[0]}< #{args[1]}\n")
        else
          @client.execute(command[1..-1], predicate)
        end
      end
    end

    private
      def setup_client(args)
        @client = IrcClient.new(*args)
        @client.connect

        # start timers
        @display.timerExec(250, PollRunner.new(@display, @client))
        @display.timerExec(500, ReceiveRunner.new(@display, @client, self))
      end
  end
end
