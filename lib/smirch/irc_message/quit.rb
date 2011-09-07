module Smirch
  module IrcMessage
    class Quit < Base
      def to_s
        "* %s (%s@%s) has quit (%s)" % [from.nick, from.user, from.host, @text]
      end

      private
        def setup(command, middle, trailing)
          @text = trailing
        end
    end
  end
end
