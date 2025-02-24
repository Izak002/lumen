# dependencies -------------------------------------------------

require "httparty"
require "dotenv"
require "terminal-table"
Dotenv.load

# ---------------------------------------------------------------

class Weather

  include HTTParty
  # set up logger [make httparty use my logger even thought theirs is a lot better ✨]
  logger Scriptorium.new, :api_call
  # set the class level information
  base_uri "https://api.openweathermap.org/data/2.5"
  format :json
  default_params appid: ENV["WEATHER_API_KEY"], units: "metric"

  COLOURS = {
    reset: "\e[0m",
    red: "\e[31m",
    green: "\e[32m",
    yellow: "\e[33m",
    blue: "\e[34m",
    magenta: "\e[35m",
    cyan: "\e[36m",
    light_black: "\e[90m",
    light_red: "\e[91m",
    light_cyan: "\e[96m",
    white: "\e[97m"
  }.freeze

  # getting weather information -----------------------------------

  def fetch(location)
    logger = self.class.default_options[:logger]
    logger.debug("Fetching data from weather api")

    response = self.class.get("/weather", query: { q: location })

    raise response["message"] if response.code != 200

    logger.success("Successfully retrieved weather data")

    @weather_data = parse_weather(response)
  rescue => e
    logger.error("#{e.message}")
  end

  def display()
    return unless @weather_data

    table = Terminal::Table.new do |t|
      t.title = "#{weather_emoji(@weather_data[:condition])}  #{@weather_data[:location]}  #{weather_emoji(@weather_data[:condition])}"
      t.style = { all_separators: true, border: :unicode }
      t << [{ value: "Current Weather", colspan: 2, alignment: :center }]

      add_weather_row(t, "Temperature", "#{@weather_data[:temp]}°C", temp_colour(@weather_data[:temp]))
      add_weather_row(t, "Feels Like", "#{@weather_data[:feels_like]}°C", :light_black)
      add_weather_row(t, "Condition", @weather_data[:condition], condition_colour(@weather_data[:condition]))
      add_weather_row(t, "Description", @weather_data[:description], :cyan)
      add_weather_row(t, "Humidity", "#{@weather_data[:humidity]}%", :light_cyan)
      add_weather_row(t, "Wind Speed", "#{@weather_data[:wind_speed]} m/s", :blue)
      add_weather_row(t, "Visibility", "#{@weather_data[:visibility]} km", :white)
      add_weather_row(t, "Sunrise", @weather_data[:sunrise], :yellow)
      add_weather_row(t, "Sunset", @weather_data[:sunset], :magenta)
    end

    puts table
  end

  def update_readme
    readme_path = File.join(CLONE_DIR, "README.md")
    start_marker = "<!-- WEATHER START -->"
    end_marker = "<!-- WEATHER END -->"
  
    return unless @weather_data
  
    table_text = <<~WEATHER
      ```
      #{Terminal::Table.new do |t|
          t.title = "#{@weather_data[:location]}"
          t.style = { all_separators: true, border: :unicode }
          t << [{ value: "Current Weather", colspan: 2, alignment: :center }]
  
          t << ["Temperature:", "#{@weather_data[:temp]}°C"]
          t << ["Feels Like:", "#{@weather_data[:feels_like]}°C"]
          t << ["Condition:", @weather_data[:condition]]
          t << ["Description:", @weather_data[:description]]
          t << ["Humidity:", "#{@weather_data[:humidity]}%"]
          t << ["Wind Speed:", "#{@weather_data[:wind_speed]} m/s"]
          t << ["Visibility:", "#{@weather_data[:visibility]} km"]
          t << ["Sunrise:", @weather_data[:sunrise]]
          t << ["Sunset:", @weather_data[:sunset]]
        end}
      ```
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

  def apply_colour(str, colour)
    return str unless COLOURS[colour]
    "#{COLOURS[colour]}#{str}#{COLOURS[:reset]}"
  end

  def add_weather_row(table, label, value, colour)
    table << [
      apply_colour("#{label}:", :light_black),
      apply_colour(value.to_s, colour)
    ]
  end

  def temp_colour(temp)
    case temp
    when 30.. then :red
    when 25..29 then :yellow
    when 10..24 then :green
    else :blue
    end
  end

  def condition_colour(condition)
    case condition.downcase
    when "clear" then :yellow
    when "clouds" then :light_black
    when "rain", "drizzle" then :blue
    when "thunderstorm" then :magenta
    when "snow" then :white
    else :cyan
    end
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
