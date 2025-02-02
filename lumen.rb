# dependencies -------------------------------------------------------------

require_relative "lib/utils/scriptorium"
require_relative "lib/weather"

#  -------------------------------------------------------------------------

logger = Scriptorium.new

#  TODO
#  => get weather info
#  => add current date

logger.info("Getting weather information.....")
weather = Weather.new()
weather.fetch("Cape Town")
weather.display