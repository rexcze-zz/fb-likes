require_relative 'config/capybara'
require_relative 'config/facebook'

class Scraper
  include Capybara::DSL

  class PageDoesNotExist < StandardError; end

  MAX_LIKES = 400
  FB_SITE = 'https://www.facebook.com/'
  SELECTOR = 'div.fsl.fwb.fcb a'

  def initialize
    @session = Capybara::Session.new(:webkit)
  end

  def get_data(user_id)
    @session.visit "#{FB_SITE}app_scoped_user_id/#{user_id}/"
    @session.visit "#{@session.current_url}/likes"

    raise PageDoesNotExist if @session.has_css?('div#error')

    load_all_elems
    @session.all(SELECTOR).map { |link| link[:href] }
  end

  def login
    @session.visit(FB_SITE)
    @session.fill_in 'email', with: Config::Facebook.username
    @session.fill_in 'pass', with: Config::Facebook.password
    @session.find('input[type=submit]').click
  end

  private

  def load_all_elems
    loop do
      current_elems_count = elems_count
      scroll_page
      wait_for_ajax(current_elems_count)

      break if elems_count >= MAX_LIKES

      # No new content
      if current_elems_count == elems_count
        # Try for the last time
        scroll_page
        wait_for_ajax(current_elems_count)
        break if current_elems_count == elems_count
      end
    end
  end

  def wait_for_ajax(current_elems_count)
    wait_time = 0
    interval = 0.1

    loop do
      sleep interval
      wait_time += interval

      break if current_elems_count != elems_count
      break if wait_time >= 10
    end
  end

  def elems_count
    @session.all(SELECTOR).count
  end

  def scroll_page
    @session.execute_script 'window.scrollBy(0,10000)'
  end
end
