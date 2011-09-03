module Smirch
  class Command
    attr_reader :name

    def initialize(name, options = {}, &block)
      @name = name
      @args = options[:args] || []
      @block = block
    end

    def execute(string = nil)
      args = string ? string.split(/\s+/, @args.length) : []
      if args.length == @args.length
        @block.call(*args)
        true
      else
        :syntax_error
      end
    end

    def syntax
      @syntax ||= @args.empty? ? "/#{@name}" : "/#{@name} <#{@args.join('> <')}>"
    end
  end
end
