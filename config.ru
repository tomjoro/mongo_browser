$:.unshift File.expand_path("..", __FILE__)
require 'app.rb'

# Sinatra Settings
set :environment, :development
set :run, false

set :static, true
set :public_folder, File.dirname(__FILE__) + '/public'

# App Settings
set :split_char, '/'

run Sinatra::Application
