module Smirch
  class SettingsDialog
    def initialize(parent, event)
      dialog = Widgets::Shell.new(parent, SWT::DIALOG_TRIM | SWT::PRIMARY_MODAL)
      layout = Layout::GridLayout.new(2, false)
      dialog.layout = layout

      server_label = Widgets::Label.new(dialog, SWT::LEFT)
      server_label.text = "Server"
      server_input = Widgets::Text.new(dialog, SWT::BORDER)
      server_input.layout_data = Layout::GridData.new(150, SWT::DEFAULT)

      port_label = Widgets::Label.new(dialog, SWT::LEFT)
      port_label.text = "Port"
      port_input = Widgets::Text.new(dialog, SWT::BORDER)
      port_input.layout_data = Layout::GridData.new(150, SWT::DEFAULT)

      nick_label = Widgets::Label.new(dialog, SWT::LEFT)
      nick_label.text = "Nick"
      nick_input = Widgets::Text.new(dialog, SWT::BORDER)
      nick_input.layout_data = Layout::GridData.new(150, SWT::DEFAULT)

      user_label = Widgets::Label.new(dialog, SWT::LEFT)
      user_label.text = "User"
      user_input = Widgets::Text.new(dialog, SWT::BORDER)
      user_input.layout_data = Layout::GridData.new(150, SWT::DEFAULT)

      real_label = Widgets::Label.new(dialog, SWT::LEFT)
      real_label.text = "Real Name"
      real_input = Widgets::Text.new(dialog, SWT::BORDER)
      real_input.layout_data = Layout::GridData.new(150, SWT::DEFAULT)

      save_button = Widgets::Button.new(dialog, SWT::PUSH)
      save_button.text = "Save"
      save_button.layout_data = Layout::GridData.new(SWT::LEFT, SWT::CENTER, false, false)
      save_button.add_selection_listener do |e|
      end

      cancel_button = Widgets::Button.new(dialog, SWT::PUSH | SWT::RIGHT)
      cancel_button.text = "Cancel"
      cancel_button.layout_data = Layout::GridData.new(SWT::RIGHT, SWT::CENTER, false, false)
      cancel_button.add_selection_listener { |e| dialog.close }

      dialog.pack
      dialog.open
    end
  end
end
