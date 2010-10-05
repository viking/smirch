module Smirch
  module IrcMessage
    class Join < Base
      def draw(window)
        if from.me?
          window.new_tab(@channel)
        else
          tab = window.find_tab(@channel)
          tab[:text].append("* %s (%s@%s) joined %s\n" % [from.nick, from.user, from.host, @channel])
        end
      end

      private
        def setup(command, middle, trailing)
          @channel = trailing
        end
    end
  end
end
