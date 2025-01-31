require_relative "lib/utils/scriptorium"

logger = Scriptorium.new

# testing log methods
logger.debug("Initializing weather module")
logger.api_call("Fetching from weatherAPI.com")
logger.info("Hello world ........")
logger.success("Weather data retrieved!")
logger.warning("High UV index detected")
logger.error("Failed to connect to joke API")