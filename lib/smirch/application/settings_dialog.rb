module Smirch
  class Application
    class SettingsDialog
      def initialize(parent, event)
        config = Smirch.load_config

        @shell = Swt::Widgets::Shell.new(parent, Swt::SWT::DIALOG_TRIM | Swt::SWT::PRIMARY_MODAL)
        @shell.text = "Smirch Settings"
        @shell.layout = Swt::Layout::GridLayout.new(2, false)

        @inputs = {}

        server_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        server_label.text = "Server"
        @inputs['server'] = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @inputs['server'].layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @inputs['server'].text = config['server']   if config

        port_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        port_label.text = "Port"
        @inputs['port'] = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @inputs['port'].layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @inputs['port'].text = config['port'].to_s   if config

        nick_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        nick_label.text = "Nick"
        @inputs['nick'] = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @inputs['nick'].layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @inputs['nick'].text = config['nick']   if config

        user_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        user_label.text = "User"
        @inputs['user'] = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @inputs['user'].layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @inputs['user'].text = config['user']   if config

        real_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        real_label.text = "Real Name"
        @inputs['real'] = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @inputs['real'].layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @inputs['real'].text = config['real']   if config

        proxy_host_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        proxy_host_label.text = "Proxy Host"
        @inputs['proxy_host'] = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @inputs['proxy_host'].layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @inputs['proxy_host'].text = config['proxy_host']   if config

        proxy_port_label = Swt::Widgets::Label.new(@shell, Swt::SWT::LEFT)
        proxy_port_label.text = "Proxy Port"
        @inputs['proxy_port'] = Swt::Widgets::Text.new(@shell, Swt::SWT::BORDER)
        @inputs['proxy_port'].layout_data = Swt::Layout::GridData.new(150, Swt::SWT::DEFAULT)
        @inputs['proxy_port'].text = config['proxy_port'].to_s   if config

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
        config = @inputs.inject({}) do |hsh, (name, input)|
          val = input.text.empty? ? nil : input.text
          if (name == 'port' || name == 'proxy_port') && val
            val = val.to_i
          end
          hsh[name] = val
          hsh
        end
        Smirch.save_config(config)
        @shell.close
      end
    end
  end
end
