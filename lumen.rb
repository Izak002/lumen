# dependencies -------------------------------------------------------------

require_relative "lib/utils/scriptorium"
require_relative "lib/weather"
require_relative "lib/github_stats"
require "git"

#  -------------------------------------------------------------------------

# Repository details
REPO_URL = "git@github.com:Izak002/Izak002.git"
CLONE_DIR = "cloned_repo"

# get personal readme
if Dir.exist?(CLONE_DIR)
    puts "Repository already cloned. Pulling latest changes..."
    repo = Git.open(CLONE_DIR)
    repo.pull
  else
    puts "Cloning repository..."
    repo = Git.clone(REPO_URL, CLONE_DIR)
end

# logger = Scriptorium.new

# logger.info("Getting weather information.....")
weather = Weather.new()
weather.fetch("Cape Town")
weather.update_readme

# weather.display

# logger.info("Gettig github stats information....")
github_stats = GithubStats.new
github_stats.update_readme
# github_stats.display_stats

