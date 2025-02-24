# dependencies -------------------------------------------------------------

require_relative "lib/utils/scriptorium"
require_relative "lib/weather"
require_relative "lib/github_stats"

#  -------------------------------------------------------------------------

# logger = Scriptorium.new

# logger.info("Getting weather information.....")
weather = Weather.new()
weather.fetch("Cape Town")
weather.update_readme()

# weather.display

# logger.info("Gettig github stats information....")
github_stats = GithubStats.new
github_stats.update_readme
# github_stats.display_stats