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
        klass = case command
          when /^\d{3}$/  then IrcMessage::Numeric
          when /^[A-Z]+$/
            IrcMessage.const_get(command[0..0] + command[1..-1].downcase)
        end
      rescue
        puts "ERROR, no class found: #{text.inspect}"
        return nil
      end

      klass.new(result)
    end
  end
end

%w{base ctc entity join mode nick numeric part quit}.each do |f|
  require(File.dirname(__FILE__) + "/irc_message/#{f}")
end
