class Smirch
  module Message
    def self.parse(text)
      parser = MessageParser.new
      result = parser.parse(text)

      command = result.command.text_value
      klass = case command
        when /^\d{3}$/  then Message::Numeric
        when /^[A-Z]+$/
          Message.const_get(command[0..0] + command[1..-1].downcase)
        end

      klass.new(result)
    end
  end
end

re = /base\.rb$/
Dir[File.dirname(__FILE__) + "/message/*.rb"].sort { |a, b| a =~ re ? -1 : b =~ re ? 1 : a <=> b }.each { |f| require(f) }
