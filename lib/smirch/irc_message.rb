module Smirch
  module IrcMessage
    def self.parse(text)
      parser = IrcMessageParser.new
      result = parser.parse(text)
      if result.nil?
        puts "ERROR, couldn't parse: #{text.inspect}"
        return nil
      end

      command = result.command.text_value
      begin
        klass =
          case command
          when /^\d{3}$/
            IrcMessage::Numeric.get_class(command)
          when /^[A-Z]+$/
            IrcMessage.const_get(command[0..0] + command[1..-1].downcase)
          end
        klass.new(result)
      rescue
        puts "ERROR, no class found: #{text.inspect}"
        nil
      end
    end
  end
end

%w{base ctc join mode nick numeric part ping quit}.each do |f|
  require(File.dirname(__FILE__) + "/irc_message/#{f}")
end
