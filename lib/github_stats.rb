# dependencies ----------------------------------------------------------

require "octokit"
require "dotenv"
Dotenv.load

#  ----------------------------------------------------------------------

class GithubStats

  ACCESS_TOKEN = ENV["GITHUB_API"]
  raise "Please set the GITHUB_ACCESS token environment variable." unless ACCESS_TOKEN

  def initialize
    @client = Octokit::Client.new(access_token: ACCESS_TOKEN)
    @client.auto_paginate = true
    @user = @client.user
  end

  def display_stats
    stats = fetch_stats
    display_table(stats)
    generate_midi_song
  end

  private

  def fetch_stats
  end

  def display_table
  end

  def generate_midi_song
  end



end
