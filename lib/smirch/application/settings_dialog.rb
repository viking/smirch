module Smirch
  class Application
    class SettingsDialog
      def initialize(parent, event)
        config = Smirch.load_config

        @shell = Widgets::Shell.new(parent, SWT::DIALOG_TRIM | SWT::PRIMARY_MODAL)
        @shell.text = "Smirch Settings"
        @shell.layout = Layout::GridLayout.new(2, false)

        server_label = Widgets::Label.new(@shell, SWT::LEFT)
        server_label.text = "Server"
        @server_input = Widgets::Text.new(@shell, SWT::BORDER)
        @server_input.layout_data = Layout::GridData.new(150, SWT::DEFAULT)
        @server_input.text = config['server']   if config

        port_label = Widgets::Label.new(@shell, SWT::LEFT)
        port_label.text = "Port"
        @port_input = Widgets::Text.new(@shell, SWT::BORDER)
        @port_input.layout_data = Layout::GridData.new(150, SWT::DEFAULT)
        @port_input.text = config['port'].to_s   if config

        nick_label = Widgets::Label.new(@shell, SWT::LEFT)
        nick_label.text = "Nick"
        @nick_input = Widgets::Text.new(@shell, SWT::BORDER)
        @nick_input.layout_data = Layout::GridData.new(150, SWT::DEFAULT)
        @nick_input.text = config['nick']   if config

        user_label = Widgets::Label.new(@shell, SWT::LEFT)
        user_label.text = "User"
        @user_input = Widgets::Text.new(@shell, SWT::BORDER)
        @user_input.layout_data = Layout::GridData.new(150, SWT::DEFAULT)
        @user_input.text = config['user']   if config

        real_label = Widgets::Label.new(@shell, SWT::LEFT)
        real_label.text = "Real Name"
        @real_input = Widgets::Text.new(@shell, SWT::BORDER)
        @real_input.layout_data = Layout::GridData.new(150, SWT::DEFAULT)
        @real_input.text = config['real']   if config

        save_button = Widgets::Button.new(@shell, SWT::PUSH)
        save_button.text = "Save"
        save_button.layout_data = Layout::GridData.new(SWT::LEFT, SWT::CENTER, false, false)
        save_button.add_selection_listener { |e| save(e) }

        cancel_button = Widgets::Button.new(@shell, SWT::PUSH | SWT::RIGHT)
        cancel_button.text = "Cancel"
        cancel_button.layout_data = Layout::GridData.new(SWT::RIGHT, SWT::CENTER, false, false)
        cancel_button.add_selection_listener { |e| @shell.close }

        @shell.pack
        @shell.open
      end

      def save(event)
        config = {
          'server' => @server_input.text,
          'port' => @port_input.text.to_i,
          'nick' => @nick_input.text,
          'user' => @user_input.text,
          'real' => @real_input.text,
        }
        Smirch.save_config(config)
        @shell.close
      end
    end
  end
end
