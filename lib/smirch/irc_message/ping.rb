module Smirch
  module IrcMessage
    class Ping < Base
      private
        def setup(command, middle, trailing)
          @text = trailing
        end
    end
  end
end
