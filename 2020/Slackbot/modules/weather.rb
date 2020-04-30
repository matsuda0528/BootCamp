require 'get_json'

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
