module Smirch
  module GUI
    class Swt
      include ::Swt
      attr_reader :current_tab

      def initialize(app, title)
        @app = app
        @display = ::Swt.display
        @shell = Widgets::Shell.new(@display)
        @shell.text = title
        @shell.layout = Layout::GridLayout.new(1, true)
        setup_colors_and_fonts
        setup_menu
        setup_tabs
        setup_input
      end

      def main_loop
        @shell.open
        while (!@shell.disposed?) do
          @display.sleep   if !@display.read_and_dispatch
        end
        @display.dispose
      end

      def update(event, *args)
        # TODO: use Smirch::Event or something
        @display.async_exec do
          case event
          when :client_connecting
            current_tab.chat_box.append("Connecting...\n")
          when :client_connected
            current_tab.chat_box.append("Connected!\n")
          when :privmsg
            current_tab.chat_box.append(">#{args[0]}< #{args[1]}\n")
          when :connection_required
            current_tab.chat_box.append("You have to connect to a server first to do that.\n")
          when :message_received
            process_message(args[0])
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
        @tab_folder.add_selection_listener do |event|
          @current_tab = @tabs[@tab_folder.selection_index]
        end
        @current_tab = new_tab("Server")
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

      def input_received
        input = @input_box.text
        @input_box.text = ""
        @app.execute(input)
      end

      def new_tab(name)
        tab = Tab.new(@tab_folder, name, {
          :background => @black,
          :foreground => @white,
          :font => @font_18
        })
        @tab_folder.selection = tab.tab_item
        @tabs << tab
        tab
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

      def print(str, tab_name = nil)
        tab = tab_name ? find_tab(tab_name) : current_tab
        tab.chat_box.append(str + "\n")
      end

      def process_message(message)
        case message
        when IrcMessage::Join
          if message.from.me?
            new_tab(message.channel_name)
          else
            print(message.to_s, message.channel_name)
          end
        when IrcMessage::Part
          if message.from.me?
            close_tab(message.channel_name)
          else
            print(message.to_s, message.channel_name)
          end
        else
          if message.channel_name
            print(message.to_s, message.channel_name)
          #elsif message.from.server?
          else
            print(message.to_s, 'Server')
          end
        end
      end
    end
  end
end

path = Pathname.new(File.dirname(__FILE__)) + 'swt'
require path + 'tab'
require path + 'settings_dialog'
