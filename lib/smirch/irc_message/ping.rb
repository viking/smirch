module Smirch
  module IrcMessage
    class Ping < Base
      def process(app, client)
        client.execute("PONG")
      end

      private
        def setup(command, middle, trailing)
          @text = trailing
        end
    end
  end
end
