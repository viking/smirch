module Smirch
  module IrcMessage
    class Part < Base
      def to_s
        if from.me?
          ""
        else
          "* %s (%s@%s) left %s" % [from.nick, from.user, from.host, @channel_name]
        end
      end

      private
        def setup(command, middle, trailing)
          @channel_name = middle[0]
          @text = trailing
        end
    end
  end
end
