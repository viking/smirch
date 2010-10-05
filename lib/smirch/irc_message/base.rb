module Smirch
  module IrcMessage
    class Base
      attr_reader :from, :to, :text, :code, :channel

      def initialize(root)
        @raw = root.text_value
        common_setup(root)
      end

      def draw(window)
        p @raw
        chat_box = window.current_chat_box
        chat_box.append("#{@text}\n")
      end

      protected
        def common_setup(root)
          node = root.prefix_expression.origin
          opts = { :type => node.type }
          if node.type == :client
            opts[:nick] = node.nick.text_value
            user_info = node.elements[1]
            if !user_info.empty?
              opts[:user] = user_info.user.text_value
              opts[:host] = user_info.host_name_or_cloak.text_value
            end
          end
          @from = Entity.new(node.text_value, opts)

          middle = []
          node = root.params.elements[1]
          while node.respond_to?(:middle)
            middle << node.middle.text_value
            node = node.params.elements[1]
          end
          trailing = node.respond_to?(:trailing) ? node.trailing.text_value : nil
          setup(root.command.text_value, middle, trailing)
        end

        def setup(command, middle, trailing)
          raise NotImplementedError
        end
    end
  end
end
