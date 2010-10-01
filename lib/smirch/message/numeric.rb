class Smirch
  module Message
    class Numeric < Base
      private
        def setup(command, middle, trailing)
          @code = command.to_i

          case command
          when "005"
            @text = middle[1..-1].join(" ") + " #{trailing}"
          else
            @text = trailing.nil? ? middle[1..-1].join(" ") : trailing
          end
        end
    end
  end
end
