class Smirch
  module Message
    class Notice < Base
      private
        def setup(command, middle, trailing)
          @text = trailing
        end
    end
  end
end
