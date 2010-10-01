class Smirch
  module Message
    class Base
      attr_reader :from, :text, :code, :channel

      def initialize(root)
        common_setup(root)
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
      #attr_reader :command, :origin, :recipient, :text, :channel

      #def initialize(command, origin, recipient, text)
        #@command = command
        #@origin = origin
        #@recipient = recipient
        #@text = text
        #additional_setup
      #end

      #private
        #def additional_setup
          #case command
          #when 'JOIN'
            #@channel = Entity.new(@text, :type => :channel)
          #end
        #end
    end
  end
end
