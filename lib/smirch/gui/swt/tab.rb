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
          @character_count = 0
          @tab_item.control = @chat_box
        end

        def dispose
          @chat_box.dispose
          @chat_box = nil
          @tab_item.dispose
          @tab_item = nil
        end

        def append(str, newline = true)
          str = newline ? str + "\n" : str
          @chat_box.append(str)
          @chat_box.top_index = @chat_box.line_count - 1
          @character_count += str.length
        end

        def append_chat_message(nick, msg, opts = {})
          str = "<#{nick}> #{msg}\n"
          append(str, false)

          if opts[:nick_foreground] && opts[:nick_background]
            # This is thread-safe, since it runs inside of an asyncExec call
            range = Custom::StyleRange.new(@character_count - str.length + 1, nick.length, opts[:nick_foreground], opts[:nick_background])
            @chat_box.style_range = range   # setStyleRange is kind of misnamed, since it adds a style
          end
        end
      end
    end
  end
end
