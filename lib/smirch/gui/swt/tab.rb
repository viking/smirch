module Smirch
  module GUI
    class Swt
      class Tab
        include ::Swt
        attr_reader :name, :tab_item, :chat_box

        def initialize(parent, name, options)
          @name = name
          @tab_item = Swt::Widgets::TabItem.new(parent, Swt::SWT::NONE)
          @tab_item.text = name
          @chat_box = Swt::Custom::StyledText.new(parent, Swt::SWT::BORDER | Swt::SWT::MULTI | Swt::SWT::V_SCROLL | Swt::SWT::READ_ONLY)
          @chat_box.background = options[:background]
          @chat_box.foreground = options[:foreground]
          @chat_box.font = options[:font]
          @tab_item.control = @chat_box
        end

        def dispose
          @chat_box.dispose
          @chat_box = nil
          @tab_item.dispose
          @tab_item = nil
        end

        def append_to_chat_box(str)
          @chat_box.append(str)
          @chat_box.top_index = @chat_box.line_count - 1
        end
      end
    end
  end
end
