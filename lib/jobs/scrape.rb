require 'sidekiq'
require 'multi_json'
require 'timeout'

require_relative '../config/app'
require_relative '../config/sidekiq'
require_relative '../config/redis'
require_relative '../scraper'

class Scrape
  include Sidekiq::Worker

  sidekiq_options retry: 5, queue: :scraping, backtrace: false

  def perform(user_id, type, limited, timeout)
    redis = Config::Redis.connection
    key = Config::Redis.method("key_#{type}").call
    logger.info "Processing: #{user_id}"

    # Data already scraped
    if redis.hexists(key, user_id)
      logger.warn 'Already processed'
      return
    end

    begin
      scraper = Scraper.new
      scraper.login

      data = []
      Timeout::timeout(real_timeout(timeout, limited)) do
        data = scraper.method("get_#{type}").call(user_id, limited)
      end
    rescue Scraper::PageDoesNotExist => e
      logger.error e.message
      return
    ensure
      scraper.close_session
    end

    logger.info "Number of results: #{data.size}"
    redis.hset(key, user_id, MultiJson.dump(data))
  end

  private

  def real_timeout(timeout, limited)
    return timeout if timeout
    return Config::App::JOB_TIMEOUT if limited
    Config::App::NOLIMIT_JOB_TIMEOUT
  end
end
