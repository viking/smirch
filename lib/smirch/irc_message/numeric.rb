module Smirch
  module IrcMessage
    class Numeric < Base
      CODE_CLASSES = {
        '353' => 'Names'
      }

      def self.get_class(code)
        if CODE_CLASSES.has_key?(code)
          IrcMessage.const_get(CODE_CLASSES[code])
        else
          Numeric
        end
      end

      def to_s
        "* #{@text}"
      end

      private
        def setup(command, middle, trailing)
          @code = command.to_i
          @to = middle[0]

          case @code
          when 5, 252, 253, 254
            @text = middle[1..-1].join(" ") + " #{trailing}"
          when 324, 328, 329, 332, 333, 366
            @channel_name = middle[1]

            case @code
            when 324, 329
              @text = middle[-1]
            when 333
              @text = middle[2..-1].join(" ")
            end
          when 353
            @channel_name = middle[2]
          end
          @text ||= trailing.nil? ? middle[1..-1].join(" ") : trailing
        end
    end

    class Names < Numeric
    end
  end
end
