module Smirch
  module IrcMessage
    class Mode < Base
      private
        def setup(command, middle, trailing)
          if middle[0] =~ /^#/
            @channel_name = middle[0]
            @text = middle[1..-1].join(" ")
          else
            @text = trailing
          end
        end
    end
  end
end
