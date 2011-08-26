module Smirch
  class Application
    class SettingsDialog
      def initialize(parent, event)
        config = Smirch.load_config

        @shell = Swt::Widgets::Shell.new(parent, Swt::SWT::DIALOG_TRIM | Swt::SWT::PRIMARY_MODAL)
        @shell.text = "Smirch Settings"
        @shell.layout = Swt::Layout::GridLayout.new(2, false)

        server_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        server_label.text = "Server"
        @server_input = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @server_input.layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @server_input.text = config['server']   if config

        port_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        port_label.text = "Port"
        @port_input = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @port_input.layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @port_input.text = config['port'].to_s   if config

        nick_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        nick_label.text = "Nick"
        @nick_input = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @nick_input.layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @nick_input.text = config['nick']   if config

        user_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        user_label.text = "User"
        @user_input = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @user_input.layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @user_input.text = config['user']   if config

        real_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        real_label.text = "Real Name"
        @real_input = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @real_input.layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @real_input.text = config['real']   if config

        save_button = Swt::Widgets::Button.new(@shell, Swt::SWT::PUSH)
        save_button.text = "Save"
        save_button.layout_data = Swt::Layout::GridData.new(Swt::SWT::LEFT, Swt::SWT::CENTER, false, false)
        save_button.add_selection_listener { |e| save(e) }

        cancel_button = Swt::Widgets::Button.new(@shell, Swt::SWT::PUSH | Swt::SWT::RIGHT)
        cancel_button.text = "Cancel"
        cancel_button.layout_data = Swt::Layout::GridData.new(Swt::SWT::RIGHT, Swt::SWT::CENTER, false, false)
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
