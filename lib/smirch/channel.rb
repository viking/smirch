module Smirch
  class Channel
    attr_reader :name, :nicks

    def initialize(name)
      @name = name
      @nicks = []
    end

    def push(*nicks)
      nicks.each do |nick|
        md = nick.match(/^([@+])?(.+)$/)
        @nicks.push(md[2])
      end
    end

    def delete(nick)
      @nicks.delete(nick)
    end
  end
end
