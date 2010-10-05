module Smirch
  module IrcMessage
    class Nick < Base
      private
        def setup(command, middle, trailing)
          @text = trailing
        end
    end
  end
end
