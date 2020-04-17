$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra'
require 'SlackBot'
require 'API'

class MySlackBot < SlackBot
end

slackbot = MySlackBot.new
set :environment, :production
set :port, 443
get '/' do
  "SlackBot Server"
end

post '/slack' do
  content_type :json
  text = params[:text].split("@matsudabot ")[1]
  
  if text.include?("天気")
    msg = Weather.forecast(text.split("の")[0])
    msg = "#{text.split("の")[0]}は観測地点に登録されていません．" if msg == nil
    slackbot.post_message(msg,username:"matsudabot")
  end
end
