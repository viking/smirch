module Smirch
  module IrcMessage
    class Join < Base
      def process(app, client)
        if from.me?
          app.new_tab(@channel_name)
        else
          tab = app.find_tab(@channel_name)
          tab[:text].append("* %s (%s@%s) joined %s\n" % [from.nick, from.user, from.host, @channel_name])
        end
      end

      private
        def setup(command, middle, trailing)
          @channel_name = trailing
        end
    end
  end
end
