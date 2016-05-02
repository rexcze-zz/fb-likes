require 'sidekiq'
require 'multi_json'
require_relative 'config/sidekiq'
require_relative 'config/redis'
require_relative 'scraper'

class Worker
  include Sidekiq::Worker

  sidekiq_options retry: 5, queue: :likes, backtrace: false

  # Job should be repeated after 10 minutes if it fails
  # sidekiq_retry_in do
  #   600
  # end

  def perform(user_id)
    redis = Config::Redis.connection

    # Data already scraped
    return if redis.hexists(Config::Redis.key, user_id)

    scraper = Scraper.new
    scraper.login

    begin
      data = scraper.get_data(user_id)
    rescue Scraper::PageDoesNotExist, Scraper::NoLikesFound
      logger.error "#{user_id}: Likes could not be retrieved"
      return
    end

    redis.hset(Config::Redis.key, user_id, MultiJson.dump(data))
  end
end
