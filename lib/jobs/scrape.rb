require 'sidekiq'
require 'multi_json'

require_relative '../config/sidekiq'
require_relative '../config/redis'
require_relative '../scraper'

class Scrape
  include Sidekiq::Worker

  sidekiq_options retry: 5, queue: :scraping, backtrace: false

  def perform(user_id, type, limited)
    redis = Config::Redis.connection
    key = Config::Redis.method("key_#{type}").call

    # Data already scraped
    return if redis.hexists(key, user_id)

    scraper = Scraper.new
    scraper.login

    begin
      data = scraper.method("get_#{type}").call(user_id, limited)
    rescue Scraper::PageDoesNotExist => e
      logger.error e.message
      return
    end

    redis.hset(key, user_id, MultiJson.dump(data))
  end
end
