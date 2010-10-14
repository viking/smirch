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
    end

    class Privmsg < CTC
      def process(app, client)
        if @channel_name
          app.print("<%s> %s\n" % [from.nick, @text], @channel_name)
        else
          super
        end
      end
    end
  end
end
