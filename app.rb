require 'rubygems'
require 'sinatra'
require 'open-uri'

require 'dir_list'
require 'mongo_list'

enable :sessions

MongoList.connect('localhost')

# Set utf-8 for outgoing
before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

# Helpers
helpers do
  def site_title
    'Mongo Browser using JQueryTree running on Sinatra'
  end
end

get '/*' do
  erb :index
end

post '/jqueryfiletree/content' do
  path = URI::decode( params[:dir] ).strip
  puts "  Post request: #{path}"
  path << settings.split_char unless path[-1, 1] == settings.split_char
  @results = []
  begin
    @results = MongoList.list_dir(settings.split_char,  path)
  rescue  MongoList::MongoListError => e
    puts "Error: couldn't open folder: #{e}"
  end
  erb :jquerytree, :layout => false
end


