# coding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra'
require 'SlackBot'
require 'OpenClass' 
require 'modules/weather'
require 'modules/news'
require 'modules/quiz'

class MySlackBot < SlackBot
  def initialize
    super
    @playing_quiz = false
  end

  def playing_quiz?
    @playing_quiz
  end

  def start_quiz
    @playing_quiz = true
  end

  def stop_quiz
    @playing_quiz = false
  end
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
  
  if text.include?("と言って")
    msg = text.split("と言って")[0]
    slackbot.post_message(msg,username:"matsudabot")
  end

  if text.include?("天気")
    city = text.split("の")[0]
    msg = WeatherAPI.get(city)
    slackbot.post_message(msg,username:"matsudabot")
  end

  if text.include?("ニュース")
    number = text.include?("件") ? text.extract_numbers : 1
    if text.include?("\"")
      keyword = text.split("\"")[1]
      msg = NewsAPI.find(number,keyword)
    else
      msg = NewsAPI.get(number)
    end
    slackbot.post_message(msg,username:"matsudabot")
  end

  if slackbot.playing_quiz?
    msg = QuizAPI.answer(text)
    slackbot.post_message(msg,username:"matsudabot")
    slackbot.stop_quiz
  end
  if text.include?("クイズ")
    msg = QuizAPI.get
    slackbot.post_message(msg,username:"matsudabot")
    slackbot.start_quiz
  end
end
