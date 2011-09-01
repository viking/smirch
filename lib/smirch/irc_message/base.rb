module Smirch
  module IrcMessage
    class Base
      attr_reader :from, :to, :text, :code, :channel_name, :channel

      def initialize(root)
        @raw = root.text_value
        common_setup(root)
      end

      def to_s
        @raw
      end

      protected
        def common_setup(root)
          if !root.elements[0].empty?
            node = root.elements[0].origin
            opts = { :type => node.type }
            if node.type == :client
              opts[:nick] = node.nick.text_value
              user_info = node.elements[1]
              if !user_info.empty?
                opts[:user] = user_info.user.text_value
                opts[:host] = user_info.host_or_cloak.text_value
              end
            end
            @from = Entity.new(node.text_value, opts)
          end

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
