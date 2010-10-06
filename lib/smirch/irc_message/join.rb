module Smirch
  module IrcMessage
    class Join < Base
      def draw(window)
        if from.me?
          window.new_tab(@channel_name)
        else
          tab = window.find_tab(@channel_name)
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
