module Smirch
  class Application

    def initialize
      @gui = GUI::Swt.new(self, "Smirch")
      setup_commands
    end

    def execute(str)
      return if str[0] != ?/
      command_name, predicate = str[1..-1].split(/\s+/, 2)

      command = @commands.find { |c| c.name == command_name }
      if command
        predicate ? command.execute(predicate) : command.execute
      else
        require_connection do
          @client.execute(command_name, predicate)
        end
      end
    end

    def main_loop
      @gui.main_loop
    end

    def nick
      @client ? @client.nick : nil
    end

    private

    def setup_commands
      @commands = [
        Command.new('server', :args => %w{server port nick user realname}) do |server, port, nick, user, realname|
          setup_client({
            'server' => server,
            'port' => port.to_i,
            'nick' => nick,
            'user' => user,
            'real' => realname
          })
        end,
        Command.new('connect') do
          config = Smirch.load_config
          setup_client(config)
        end,
        Command.new('msg', :args => %w{recipient message}) do |recipient, message|
          require_connection do
            @client.privmsg(recipient, message)
            @gui.update(:privmsg, recipient, message)
          end
        end
      ]
    end

    def setup_client(options)
      @gui.update(:client_connecting)
      @client = IrcClient.new(options)
      Thread.new do
        @client.connect do
          @gui.update(:client_connected)
          @client.start_polling
          @check_message_thread = Thread.new do
            loop do
              #puts "Checking for messages..."
              check_client_for_messages
              sleep 0.5
            end
          end
        end
      end
    end

    def check_client_for_messages
      queue = @client.queue
      while !queue.empty?
        message = queue.shift
        @gui.update(:message_received, message)
        #message.process(self, @client)
      end
    end

    def require_connection
      if @client
        yield
      else
        @gui.update(:connection_required)
      end
    end
  end
end
