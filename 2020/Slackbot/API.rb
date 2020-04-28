require 'json'
require 'uri'
require 'net/http'

def get_json(location, limit = 10)
  raise ArgumentError, 'too many HTTP redirects' if limit == 0
  uri = URI.parse(location)
  begin
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end
    case response
    when Net::HTTPSuccess
      json = response.body
      JSON.parse(json)
    when Net::HTTPRedirection
      location = response['location']
      warn "redirected to #{location}"
      get_json(location, limit - 1)
    else
      puts [uri.to_s, response.value].join(" : ")
      # handle error
    end
  rescue => e
    puts [uri.to_s, e.class, e].join(" : ")
    # handle error
  end
end  

module WeatherAPI
  def get(city)
    city_id_list = File.open("weather_list.json") do |j|
      JSON.load(j)
    end
    return "#{city}は観測地点に登録されていません．" if city_id_list[city] == nil
    url="http://weather.livedoor.com/forecast/webservice/json/v1?city=#{city_id_list[city]}"
    json = get_json(url)
    text = <<~EOS
      #{json['forecasts'][0]['dateLabel']}の#{json['title']}
      #{json['forecasts'][0]['telop']}

      #{json['forecasts'][1]['dateLabel']}の#{json['title']}
      #{json['forecasts'][1]['telop']}

      ---

      #{json['description']['text']}
      #{json['description']['publicTime']}
    EOS
    return text
  end

  module_function :get
end

module NewsAPI
  def get(number)
    url = "https://newsapi.org/v2/top-headlines?country=jp&apiKey=#{ENV['NEWS_API_KEY']}"
    json = get_json(url)
    number = [number, json['totalResults']].min
    text = String.new
    number.times do |i|
      text += <<~EOS
        タイトル :
        #{json['articles'][i]['title']}
       
        詳細 : 
        #{json['articles'][i]['description']}

        URL :
        #{json['articles'][i]['url']}
        ---

      EOS
    end
    return text
  end

  def find(number,keyword)
    url = URI.encode "https://newsapi.org/v2/everything?language=jp&apiKey=#{ENV['NEWS_API_KEY']}&q=#{keyword}"
    json = get_json(url)
    return "\"#{keyword}\"に関するニュースは見つかりませんでした．" if json['totalResults'] == 0
    number = [number, json['totalResults']].min
    text = String.new
    number.times do |i|
    text += <<~EOS
      タイトル :
      #{json['articles'][i]['title']}

      詳細 :
      #{json['articles'][i]['description']}

      URL :
      #{json['articles'][i]['url']}
      ---

    EOS
    end
    return text
  end

  module_function :get
  module_function :find
end

module QuizAPI
  def get
    url = "https://opentdb.com/api.php?amount=1&category=18"
    @json = get_json(url)
    answers = [@json['results'][0]['correct_answer']] + @json['results'][0]['incorrect_answers']
    text = <<~EOS
      Question : 
      #{@json['results'][0]['question']}
   
      Choise:
      #{answers.sort}

    EOS
    return text 
  end

  def answer(ans)
    if ans == @json['results'][0]['correct_answer']
      text = <<~EOS
      Is the correct answer.
      EOS
    else
      text = <<~EOS
      Incorrect.
      correct answer is #{@json['results'][0]['correct_answer']}.
      EOS
    end
  end

  module_function :answer
  module_function :get
end
