module Smirch
  module IrcMessage
    class Part < Base
      def draw(window)
        if from.me?
          window.close_tab(@channel)
        else
          tab = window.find_tab(@channel)
          tab[:text].append("* %s (%s@%s) left %s\n" % [from.nick, from.user, from.host, @channel])
        end
      end

      private
        def setup(command, middle, trailing)
          @channel = middle[0]
          @text = trailing
        end
    end
  end
end
