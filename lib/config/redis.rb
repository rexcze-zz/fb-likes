require 'redis'
require 'hiredis'

module Config
  module Redis
    class << self
      def url
        @url ||= 'redis://localhost:6379/0'
      end

      def connection
        @conn ||= ::Redis.new(url: url, driver: :hiredis)
      end

      def key_likes
        @key_likes ||= 'likes'
      end

      def key_groups
        @key_groups ||= 'groups'
      end
    end
  end
end
