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
      scroll_page
      sleep 1
      break if limited && elems_count >= MAX_ELEMS
      break if all_elems_loaded?
    end
  end

  def elems_count
    @session.all(@selector).count
  end

  def scroll_page
    @session.execute_script 'window.scrollBy(0,10000)'
  end

  def all_elems_loaded?
    @session.all('div.uiHeader').count > 0
  end
end
