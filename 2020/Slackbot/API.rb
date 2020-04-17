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

module Weather
  def forecast(city)
  city_id_list = File.open("weather_list.json") do |j|
    JSON.load(j)
  end
    
    return nil if city_id_list[city] == nil

    url='http://weather.livedoor.com/forecast/webservice/json/v1?city='+city_id_list[city]
    result = get_json(url)

    text = <<~EOS
      #{result['location']['city']}の天気
      #{result['forecasts'][0]['telop']}
    EOS

    return text
  end

  module_function :forecast
end
