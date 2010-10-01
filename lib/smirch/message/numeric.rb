class Smirch
  module Message
    class Numeric < Base
      private
        def setup(command, middle, trailing)
          @code = command.to_i

          case @code
          when 5, 252, 253, 254
            @text = middle[1..-1].join(" ") + " #{trailing}"
          when 324, 328, 329, 332, 333, 366
            @channel = middle[1]

            case @code
            when 324, 329
              @text = middle[-1]
            when 333
              @text = middle[2..-1].join(" ")
            end
          when 353
            @channel = middle[2]
          end
          @text ||= trailing.nil? ? middle[1..-1].join(" ") : trailing
        end
    end
  end
end
