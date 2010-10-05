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

    attr_reader :current_chat_box

    def initialize
      @display = Widgets::Display.new
      @shell = Widgets::Shell.new(@display)
      @shell.text = "Smirch"
      @shell.layout = Layout::GridLayout.new(1, true)
      setup_colors_and_fonts
      setup_menu
      setup_tabs
      setup_input
    end

    def new_tab(name)
      tab = Widgets::TabItem.new(@tab_folder, SWT::NONE)
      tab.text = name
      chat_box = Widgets::Text.new(@tab_folder, SWT::BORDER | SWT::MULTI | SWT::V_SCROLL | SWT::READ_ONLY)
      chat_box.background = @black
      chat_box.foreground = @white
      chat_box.font = @font_18
      tab.control = chat_box
      @tab_folder.selection = tab
      @tabs << { :name => name, :text => chat_box, :tab => tab }
    end

    def find_tab(name)
      @tabs.find { |t| t[:name] == name }
    end

    def close_tab(name)
      index = (0...@tabs.length).find { |i| @tabs[i][:name] == name }
      tab = @tabs[index]
      tab[:text].dispose
      tab[:tab].dispose
      @tabs.delete_at(index)
      @tab_folder.selection = index > 0 ? index - 1 : 0
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
          require_connection do
            args = predicate.split(/\s+/, 2)
            @client.privmsg(*args)
            current_chat_box.append(">#{args[0]}< #{args[1]}\n")
          end
        else
          require_connection do
            @client.execute(command[1..-1], predicate)
          end
        end
      end
    end

    private
      def setup_colors_and_fonts
        @black = @display.system_color(SWT::COLOR_BLACK)
        @white = @display.system_color(SWT::COLOR_WHITE)
        @font_15 = Graphics::Font.new(@display, "DejaVu Sans Mono", 15, 0)
        @font_18 = Graphics::Font.new(@display, "DejaVu Sans Mono", 18, 0)
      end

      def setup_menu
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
      end

      def setup_tabs
        @tabs = []
        @tab_folder = Widgets::TabFolder.new(@shell, SWT::BORDER | SWT::BOTTOM)
        @tab_folder.layout_data = Layout::GridData.new(Layout::GridData::FILL, Layout::GridData::FILL, true, true)
        @tab_folder.add_selection_listener(Events::SelectionListener.impl { |name, event|
          # I'm using impl instead of a block because it's easier to test.  Blame Mocha, and my laziness.
          @current_chat_box = @tabs[@tab_folder.selected_index][:text]
        })
        new_tab("Server")
      end

      def setup_input
        @input_box = Widgets::Text.new(@shell, SWT::BORDER)
        grid_data = Layout::GridData.new(Layout::GridData::FILL, Layout::GridData::FILL, true, false)
        grid_data.heightHint = 25
        @input_box.layout_data = grid_data
        @input_box.add_key_listener(Events::KeyListener.impl { |name, event|
          if name == :keyPressed && event.character == SWT::CR
            input_received
          end
        })
        @input_box.font = @font_15
        @input_box.set_focus
      end

      def setup_client(args)
        @client = IrcClient.new(*args)
        @client.connect

        # start timers
        @display.timerExec(250, PollRunner.new(@display, @client))
        @display.timerExec(500, ReceiveRunner.new(@display, @client, self))
      end

      def require_connection
        if @client
          yield
        else
          current_chat_box.append("You have to connect to a server first to do that.\n")
        end
      end
  end
end
