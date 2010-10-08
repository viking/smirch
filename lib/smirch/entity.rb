module Smirch
  class Entity
    attr_reader :name, :nick, :user, :host
    attr_writer :me

    def initialize(name, opts = {})
      @name = name
      @type = opts[:type]
      @nick = opts[:nick]
      @user = opts[:user]
      @host = opts[:host]
    end

    def server?
      @type == :server
    end

    def client?
      @type == :client
    end

    def me?
      @me
    end
  end
end
