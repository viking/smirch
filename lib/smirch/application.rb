module Smirch
  class Application

    def initialize
      @gui = GUI::Swt.new(self, "Smirch")
    end

    def execute(str)
      if str[0] == ?/
        command, predicate = str.split(/\s+/, 2)

        case command
        when "/connect"
          config = Smirch.load_config
          setup_client(config)
        when "/server"
          args = predicate.split(/\s+/, 5)
          args[1] = args[1].to_i
          setup_client({
            'server' => args[0],
            'port' => args[1],
            'nick' => args[2],
            'user' => args[3],
            'real' => args[4]
          })
        when "/msg"
          require_connection do
            args = predicate.split(/\s+/, 2)
            @client.privmsg(*args)
            @gui.update(:privmsg, *args)
          end
        else
          require_connection do
            @client.execute(command[1..-1], predicate)
          end
        end
      end
    end

    def main_loop
      @gui.main_loop
    end

    private

    def setup_client(options)
      @gui.update(:client_connecting)
      @client = IrcClient.new(options)
      Thread.new do
        @client.connect do
          @gui.update(:client_connected)
          @client.start_polling
          @check_message_thread = Thread.new do
            check_client_for_messages
            sleep 0.5
          end
        end
      end
    end

    def check_client_for_messages
      queue = @client.queue
      while !queue.empty?
        message = queue.shift
        message.process(self, @client)
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
