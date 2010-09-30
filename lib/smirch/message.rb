class Smirch
  class Message
    class Entity
      attr_reader :full_name, :nick, :user, :host

      def initialize(full_name, opts = {})
        @full_name = full_name
        if opts[:type]
          @type = opts[:type]
        elsif full_name == "*"
          @type = :misc
        elsif full_name =~ /^#/
          @type = :channel
        else
          @type = :client
          @nick = full_name
        end
        @nick = opts[:nick] if opts.has_key?(:nick)
        @user = opts[:user] if opts.has_key?(:user)
        @host = opts[:host] if opts.has_key?(:host)
      end

      def server?
        @type == :server
      end

      def client?
        @type == :client
      end

      def channel?
        @type == :channel
      end
    end

    def self.parse(text)
      parser = MessageParser.new
      result = parser.parse(text)

      command = result.command.text_value

      node = result.prefix_expression.origin
      opts = { :type => node.type }
      if node.type == :client
        opts[:nick] = node.nick.text_value
        user_info = node.elements[1]
        if !user_info.empty?
          opts[:user] = user_info.user.text_value
          opts[:host] = user_info.host_name_or_cloak.text_value
        end
      end
      origin = Entity.new(node.text_value, opts)

      node = result.params.elements[1]
      if node.respond_to?(:middle)
        recipient = Entity.new(node.middle.text_value)
        node = node.params.elements[1]
      else
        recipient = nil
      end
      text = node.trailing.text_value

      Message.new(command, origin, recipient, text)
    end

    attr_reader :command, :origin, :recipient, :text, :channel

    def initialize(command, origin, recipient, text)
      @command = command
      @origin = origin
      @recipient = recipient
      @text = text
      additional_setup
    end

    private
      def additional_setup
        case command
        when 'JOIN'
          @channel = Entity.new(@text, :type => :channel)
        end
      end
  end
end
