module Smirch
  module IrcMessage
    class Join < Base
      def to_s
        if from.me?
          ""
        else
          "* %s (%s@%s) joined %s" % [from.nick, from.user, from.host, @channel_name]
        end
      end

      private
        def setup(command, middle, trailing)
          @channel_name = trailing || middle[0]
        end
    end
  end
end
