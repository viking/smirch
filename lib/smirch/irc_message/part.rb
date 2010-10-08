module Smirch
  module IrcMessage
    class Part < Base
      def process(app)
        if from.me?
          app.close_tab(@channel_name)
        else
          tab = app.find_tab(@channel_name)
          tab[:text].append("* %s (%s@%s) left %s\n" % [from.nick, from.user, from.host, @channel_name])
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
