module Smirch
  class IrcClient
    class Channel
      attr_reader :name, :users

      def initialize(name)
        @name = name
        @users = []
      end

      def push(*users)
        users.each do |user|
          md = user.match(/^([@+])?(.+)$/)
          @users.push(md[2])
        end
      end

      def delete(user)
        @users.delete(user)
      end
    end
  end
end
