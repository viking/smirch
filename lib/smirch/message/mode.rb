class Smirch
  module Message
    class Mode < Base
      private
        def setup(command, middle, trailing)
          if middle[0] =~ /^#/
            @channel = middle[0]
            @text = middle[1..-1].join(" ")
          else
            @text = trailing
          end
        end
    end
  end
end
