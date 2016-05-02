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

      def key
        @key ||= 'likes'
      end
    end
  end
end
