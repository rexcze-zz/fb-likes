require 'sidekiq'
require 'sidekiq/web'
require_relative 'lib/config/sidekiq'

run Sidekiq::Web
