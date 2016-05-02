module Config
  module Sidekiq
    class << self
      def redis_url
        @url ||= 'redis://localhost:6379/1'
      end
    end

    ::Sidekiq.configure_client do |config|
      config.redis = { url: redis_url }
    end

    ::Sidekiq.configure_server do |config|
      config.redis = { url: redis_url }
    end
  end
end
