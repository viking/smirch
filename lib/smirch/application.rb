module Smirch
  class Application
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
          message.process(@parent, @client)
        end
        @display.timerExec(500, self)
      end
    end

    attr_reader :current_tab

    def initialize
      @display = Swt.display
      @shell = Swt::Widgets::Shell.new(@display)
      @shell.text = "Smirch"
      @shell.layout = Swt::Layout::GridLayout.new(1, true)
      setup_colors_and_fonts
      setup_menu
      setup_tabs
      setup_input
    end

    def new_tab(name)
      tab = Tab.new(@tab_folder, name, {
        :background => @black,
        :foreground => @white,
        :font => @font_18
      })
      @tab_folder.selection = tab.tab_item
      @tabs << tab
    end

    def find_tab(name)
      @tabs.find { |t| t.name == name }
    end

    def close_tab(name)
      index = (0...@tabs.length).find { |i| @tabs[i].name == name }
      tab = @tabs[index]
      tab.dispose
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
            current_tab.chat_box.append(">#{args[0]}< #{args[1]}\n")
          end
        else
          require_connection do
            @client.execute(command[1..-1], predicate)
          end
        end
      end
    end

    def print(str, tab_name = nil)
      tab = tab_name ? find_tab(tab_name) : current_tab
      tab.chat_box.append(str)
    end

    private
      def setup_colors_and_fonts
        @black = @display.system_color(Swt::SWT::COLOR_BLACK)
        @white = @display.system_color(Swt::SWT::COLOR_WHITE)
        @font_15 = Swt::Graphics::Font.new(@display, "DejaVu Sans Mono", 15, 0)
        @font_18 = Swt::Graphics::Font.new(@display, "DejaVu Sans Mono", 18, 0)
      end

      def setup_menu
        menu = Swt::Widgets::Menu.new(@shell, Swt::SWT::BAR)
        @shell.menu_bar = menu
        file_item = Swt::Widgets::MenuItem.new(menu, Swt::SWT::CASCADE)
        file_item.text = "&File"
        sub_menu = Swt::Widgets::Menu.new(@shell, Swt::SWT::DROP_DOWN)
        file_item.menu = sub_menu
        config_item = Swt::Widgets::MenuItem.new(sub_menu, Swt::SWT::PUSH)
        config_item.text = "&Settings"
        config_item.add_listener(Swt::SWT::Selection) { |e| SettingsDialog.new(@shell, e) }
        quit_item = Swt::Widgets::MenuItem.new(sub_menu, Swt::SWT::PUSH)
        quit_item.text = "&Quit"
        quit_item.add_listener(Swt::SWT::Selection) { |e| @shell.close }
      end

      def setup_tabs
        @tabs = []
        @tab_folder = Swt::Widgets::TabFolder.new(@shell, Swt::SWT::BORDER | Swt::SWT::BOTTOM)
        @tab_folder.layout_data = Swt::Layout::GridData.new(Swt::Layout::GridData::FILL, Swt::Layout::GridData::FILL, true, true)
        @tab_folder.add_selection_listener do |event|
          @current_tab = @tabs[@tab_folder.selection_index]
        end
        new_tab("Server")
      end

      def setup_input
        @input_box = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        grid_data = Swt::Layout::GridData.new(Swt::Layout::GridData::FILL, Swt::Layout::GridData::FILL, true, false)
        grid_data.heightHint = 25
        @input_box.layout_data = grid_data
        @input_box.add_key_listener(Swt::Events::KeyListener.impl { |name, event|
          if name == :keyPressed && event.character == Swt::SWT::CR
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
        @client.start_polling
        @display.timerExec(500, ReceiveRunner.new(@display, @client, self))
      end

      def require_connection
        if @client
          yield
        else
          current_tab.chat_box.append("You have to connect to a server first to do that.\n")
        end
      end
  end
end

require File.dirname(__FILE__) + "/application/settings_dialog"
require File.dirname(__FILE__) + "/application/tab"
