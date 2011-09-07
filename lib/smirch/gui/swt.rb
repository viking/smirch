module Smirch
  module GUI
    class Swt
      include ::Swt
      attr_reader :current_tab

      def initialize(app, title)
        @app = app
        @display = ::Swt.display
        @shell = Widgets::Shell.new(@display, SWT::SHELL_TRIM)
        @shell.text = title
        @shell.layout = Layout::GridLayout.new(1, true)
        @colorizer = NickColorizer.new
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
            print("Connecting...", 'Server');
          when :client_connected
            print("Connected!", 'Server');
          when :client_disconnected
            @tabs.each do |tab|
              print("Disconnected.", tab)
            end
          when :privmsg
            if tab = find_tab(args[0])
              print("<#{@app.nick}> #{args[1]}", tab)
            else
              print(">#{args[0]}< #{args[1]}")
            end
          when :connection_required
            print("You have to connect to a server first to do that.")
          when :syntax_error
            print("Syntax: #{args[0]}")
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
          if name == :keyPressed
            case event.character
            when SWT::CR
              input_received
            end
          end
        })
        @input_box.add_traverse_listener do |event|
          if event.detail == SWT::TRAVERSE_TAB_NEXT
            tab_complete
            event.doit = false
          end
        end
        @input_box.font = @font_15
        @input_box.set_focus
      end

      def input_received
        input = @input_box.text
        @input_box.text = ""
        puts "#{current_tab.name}: #{input}"
        if input[0] == ?/
          @app.execute(input)
        elsif current_tab.name != "Server"
          @app.execute("/msg #{current_tab.name} #{input}")
        end
      end

      def tab_complete
        return if current_tab.name == "Server"

        channel = @app.channels[current_tab.name]
        md = @input_box.text.match(/\S+$/)
        if md
          nick = channel.nicks.detect { |n| n =~ /^#{md[0]}/ }
          if nick
            str = nick[md[0].length..-1] + (md.begin(0) == 0 ? ": " : " ")
            @input_box.append(str)
          end
        end
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

      def find_or_create_tab(name)
        find_tab(name) || new_tab(name)
      end

      def close_tab(name)
        index = (0...@tabs.length).find { |i| @tabs[i].name == name }
        tab = @tabs[index]
        tab.dispose
        @tabs.delete_at(index)
        @tab_folder.selection = index > 0 ? index - 1 : 0
      end

      def print(str, tab_or_tab_name = nil)
        tab =
          case tab_or_tab_name
          when Swt::Tab
            tab_or_tab_name
          when String
            find_tab(tab_or_tab_name)
          when nil
            current_tab
          end

        tab.append(str)
      end

      def print_chat_message(nick, str, channel_or_nick)
        color_array = @colorizer.color_for(nick)
        foreground = Graphics::Color.new(@display, *color_array)
        tab = find_tab(channel_or_nick)
        tab.append_chat_message(nick, str, {
          :nick_foreground => foreground,
          :nick_background => @black,
        })
        foreground.dispose
      end

      def process_message(message)
        case message
        when IrcMessage::Join
          if message.from.me?
            @current_tab = new_tab(message.channel_name)
          else
            print(message.to_s, message.channel_name)
          end
        when IrcMessage::Part
          if message.from.me?
            close_tab(message.channel_name)
          else
            print(message.to_s, message.channel_name)
          end
        when IrcMessage::Quit
          if !message.from.me?
            @app.channels.each_pair do |channel_name, channel|
              if channel.has_nick?(message.from.nick)
                print(message.to_s, channel_name)
              end
            end
          end
        when IrcMessage::Privmsg
          if message.channel_name
            print_chat_message(message.from.nick, message.text, message.channel_name)
          else
            find_or_create_tab(message.from.nick)
            print_chat_message(message.from.nick, message.text, message.from.nick)
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
