module Smirch
  module GUI
    class Swt
      class Input
        include ::Swt

        def initialize(parent, font)
          @input_box = Widgets::Text.new(parent, SWT::BORDER)
          grid_data = Layout::GridData.new(Layout::GridData::FILL, Layout::GridData::FILL, true, false)
          grid_data.heightHint = 25
          @input_box.layout_data = grid_data
          @input_box.font = font
          @input_box.set_focus
        end

        def on_enter(&block)
          @input_box.add_key_listener(Events::KeyListener.impl { |name, event|
            if name == :keyPressed
              case event.character
              when SWT::CR
                block.call
              end
            end
          })
        end

        def on_tab(&block)
          @input_box.add_traverse_listener do |event|
            if event.detail == SWT::TRAVERSE_TAB_NEXT
              block.call
              event.doit = false
            end
          end
        end

        def text
          @input_box.text
        end

        def text=(t)
          @input_box.text = t
        end

        def append(t)
          @input_box.append(t)
        end
      end
    end
  end
end
