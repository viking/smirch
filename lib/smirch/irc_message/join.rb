module Smirch
  module IrcMessage
    class Join < Base
      private
        def setup(command, middle, trailing)
          @channel = trailing
        end
    end
  end
end
