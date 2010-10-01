class Smirch
  module Message
    class CTC < Base  # client-to-client
      private
        def setup(command, middle, trailing)
          if middle[0] =~ /^#/
            @channel = middle[0]
          end
          @text = trailing
        end
    end

    class Notice < CTC
    end

    class Privmsg < CTC
    end
  end
end
