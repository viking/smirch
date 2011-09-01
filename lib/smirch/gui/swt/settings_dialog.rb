module Smirch
  module GUI
    class Swt
      class SettingsDialog
        include ::Swt

        def initialize(parent, event)
          config = Smirch.load_config

          @shell = Widgets::Shell.new(parent, SWT::DIALOG_TRIM | SWT::PRIMARY_MODAL)
          @shell.text = "Smirch Settings"
          @shell.layout = Layout::GridLayout.new(2, false)

          @inputs = {}

          server_label = Widgets::Label.new(@shell, SWT::LEFT)
          server_label.text = "Server"
          @inputs['server'] = Widgets::Text.new(@shell, SWT::BORDER)
          @inputs['server'].layout_data = Layout::GridData.new(150, SWT::DEFAULT)
          @inputs['server'].text = config['server']   if config

          port_label = Widgets::Label.new(@shell, SWT::LEFT)
          port_label.text = "Port"
          @inputs['port'] = Widgets::Text.new(@shell, SWT::BORDER)
          @inputs['port'].layout_data = Layout::GridData.new(150, SWT::DEFAULT)
          @inputs['port'].text = config['port'].to_s   if config

          nick_label = Widgets::Label.new(@shell, SWT::LEFT)
          nick_label.text = "Nick"
          @inputs['nick'] = Widgets::Text.new(@shell, SWT::BORDER)
          @inputs['nick'].layout_data = Layout::GridData.new(150, SWT::DEFAULT)
          @inputs['nick'].text = config['nick']   if config

          user_label = Widgets::Label.new(@shell, SWT::LEFT)
          user_label.text = "User"
          @inputs['user'] = Widgets::Text.new(@shell, SWT::BORDER)
          @inputs['user'].layout_data = Layout::GridData.new(150, SWT::DEFAULT)
          @inputs['user'].text = config['user']   if config

          real_label = Widgets::Label.new(@shell, SWT::LEFT)
          real_label.text = "Real Name"
          @inputs['real'] = Widgets::Text.new(@shell, SWT::BORDER)
          @inputs['real'].layout_data = Layout::GridData.new(150, SWT::DEFAULT)
          @inputs['real'].text = config['real']   if config

          proxy_host_label = Widgets::Label.new(@shell, SWT::LEFT)
          proxy_host_label.text = "Proxy Host"
          @inputs['proxy_host'] = Widgets::Text.new(@shell, SWT::BORDER)
          @inputs['proxy_host'].layout_data = Layout::GridData.new(150, SWT::DEFAULT)
          @inputs['proxy_host'].text = config['proxy_host']   if config && config['proxy_host']

          proxy_port_label = Widgets::Label.new(@shell, SWT::LEFT)
          proxy_port_label.text = "Proxy Port"
          @inputs['proxy_port'] = Widgets::Text.new(@shell, SWT::BORDER)
          @inputs['proxy_port'].layout_data = Layout::GridData.new(150, SWT::DEFAULT)
          @inputs['proxy_port'].text = config['proxy_port'].to_s   if config && config['proxy_port']

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
end
