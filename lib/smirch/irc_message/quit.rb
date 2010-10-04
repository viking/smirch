module Smirch
  module IrcMessage
    class Quit < Base
      private
        def setup(command, middle, trailing)
          @text = trailing
        end
    end
  end
end
