# dependencies -------------------------------------------------

require "httparty"
require "dotenv"
Dotenv.load

# ---------------------------------------------------------------

class Weather

  include HTTParty
  # set up logger [make httparty use my logger even though theirs is a lot better ✨]
  logger Scriptorium.new, :api_call
  # set the class level information
  base_uri "https://api.openweathermap.org/data/2.5"
  format :json
  default_params appid: ENV["WEATHER_API_KEY"], units: "metric"

  def fetch(location)
    logger = self.class.default_options[:logger]
    logger.debug("Fetching data from weather api")

    response = self.class.get("/weather", query: { q: location })

    raise response["message"] if response.code != 200

    logger.success("Successfully retrieved weather data")

    @weather_data = parse_weather(response)
  rescue => e
    puts "Error: #{e.message}"
  end

  def update_readme
    readme_path = "README.md"
    start_marker = "<!-- WEATHER START -->"
    end_marker = "<!-- WEATHER END -->"
    
    return unless @weather_data

    condition_emoji = weather_emoji(@weather_data[:condition])

    table_text = <<~WEATHER
      ## #{condition_emoji} Weather Update #{condition_emoji}
      # Updated at 12 for this date 12/5/2025
      🌍 **Location:** #{@weather_data[:location]}
      
      | #{condition_emoji} Temperature | Feels Like | #{condition_emoji} Condition | 💨 Wind Speed | 💧 Humidity | 🌅 Sunrise | 🌇 Sunset |
      |--------------|------------|------------|--------------|-----------|------------|------------|
      | #{@weather_data[:temp]}°C | #{@weather_data[:feels_like]}°C | #{@weather_data[:condition]} | #{@weather_data[:wind_speed]} m/s | #{@weather_data[:humidity]}% | #{@weather_data[:sunrise]} | #{@weather_data[:sunset]} |
      
      > **#{@weather_data[:description]}**
    WEATHER
    
    content = File.read(readme_path)
    
    if content.include?(start_marker) && content.include?(end_marker)
      new_content = content.gsub(/#{start_marker}.*?#{end_marker}/m, "#{start_marker}\n#{table_text}\n#{end_marker}")
    else
      new_content = "#{content}\n\n#{start_marker}\n#{table_text}\n#{end_marker}"
    end
    
    File.write(readme_path, new_content)
  end
  
  # ---------------------------------------------------------------

  private

  def parse_weather(response)
    {
      location: "#{response["name"]}, #{response["sys"]["country"]}",
      temp: response["main"]["temp"].round,
      feels_like: response["main"]["feels_like"].round,
      condition: response["weather"].first["main"],
      description: response["weather"].first["description"].capitalize,
      humidity: response["main"]["humidity"],
      wind_speed: response["wind"]["speed"],
      sunrise: Time.at(response["sys"]["sunrise"]).strftime("%H:%M"),
      sunset: Time.at(response["sys"]["sunset"]).strftime("%H:%M"),
      visibility: response["visibility"] / 1000.0
    }
  end

  def weather_emoji(condition)
    case condition.downcase
    when "clear" then "☀️"
    when "clouds" then "☁️"
    when "rain" then "🌧️"
    when "drizzle" then "🌦️"
    when "thunderstorm" then "⛈️"
    when "snow" then "❄️"
    when "mist", "fog" then "🌫️"
    else "🌡️"
    end
  end
end
