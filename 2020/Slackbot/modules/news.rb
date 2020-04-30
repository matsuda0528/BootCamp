require 'get_json'

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

