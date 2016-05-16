require_relative 'config/capybara'
require_relative 'config/facebook'

class Scraper
  include Capybara::DSL

  class PageDoesNotExist < StandardError; end

  FB_SITE = 'https://www.facebook.com'
  MAX_ELEMS = 400

  def initialize
    @session = Capybara::Session.new(:webkit)
  end

  def login
    @session.visit(FB_SITE)
    @session.fill_in 'email', with: Config::Facebook.username
    @session.fill_in 'pass', with: Config::Facebook.password
    @session.find('input[type=submit]').click
  end

  def get_likes(user_id, limited)
    @selector = 'div.fsl.fwb.fcb a'
    visit_page_with_data(user_id, 'likes')
    load_all_elems(limited)
    @session.all(@selector).map { |link| link[:href] }
  end

  def get_groups(user_id, limited)
    @selector = 'div.mbs.fwb a'
    visit_page_with_data(user_id, 'groups')
    load_all_elems(limited)
    @session.all(@selector).map { |link| "#{FB_SITE}#{link[:href]}" }
  end

  def close_session
    driver = @session.driver
    conn = driver.instance_variable_get('@browser').instance_variable_get('@connection')
    Process.kill('TERM', conn.pid)
  end

  private

  def visit_page_with_data(user_id, type)
    @session.visit "#{FB_SITE}/app_scoped_user_id/#{user_id}/"
    @session.visit page_with_data_url(user_id, type)

    if @session.status_code == 404 || @session.has_css?('div#error')
      raise PageDoesNotExist, 'Data not available'
    end
  end

  def page_with_data_url(user_id, type)
    if @session.current_url.include?('profile.php')
      "#{@session.current_url}&sk=#{type}"
    else
      "#{@session.current_url}/#{type}"
    end
  end

  def load_all_elems(limited)
    loop do
      current_elems_count = elems_count
      scroll_page
      wait_for_ajax(current_elems_count)

      break if limited && elems_count >= MAX_ELEMS

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
    @session.all(@selector).count
  end

  def scroll_page
    @session.execute_script 'window.scrollBy(0,10000)'
  end
end
