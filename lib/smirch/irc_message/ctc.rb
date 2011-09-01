module Smirch
  module IrcMessage
    class CTC < Base  # client-to-client
      private
        def setup(command, middle, trailing)
          if middle[0] =~ /^#/
            @channel_name = middle[0]
          end
          @text = trailing
        end
    end

    class Notice < CTC
      def to_s
        if from.server?
          "* #{@text}"
        else
          super
        end
      end
    end

    class Privmsg < CTC
      def to_s
        if @channel_name
          "<%s> %s" % [from.nick, @text]
        else
          super
        end
      end
    end
  end
end
