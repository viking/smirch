module Smirch
  module IrcMessage
    class Entity
      attr_reader :name, :nick, :user, :host
      attr_writer :me

      def initialize(name, opts = {})
        @name = name
        if opts[:type]
          @type = opts[:type]
        elsif name == "*"
          @type = :misc
        elsif name =~ /^#/
          @type = :channel
        else
          @type = :client
          @nick = name
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

      def me?
        @me
      end
    end
  end
end
