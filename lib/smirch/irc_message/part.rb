module Smirch
  module IrcMessage
    class Part < Base
      private
        def setup(command, middle, trailing)
          @channel = middle[0]
          @text = trailing
        end
    end
  end
end
