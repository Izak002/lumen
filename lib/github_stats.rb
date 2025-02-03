# dependencies ----------------------------------------------------------

require "octokit"
require "dotenv"
require "midilib"
require "terminal-table"
require "date"
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
    repos = @client.repositories(@user.login)
    events = @client.user_events(@user.login)

    {
      username: @user.login,
      primary_language: calculate_primary_language(repos),
      commits: events.count { |e| e.type == "PushEvent" },
      repos: repos.count { |r| !r.fork },
      prs: events.count { |e| e.type == "PullRequestEvent" },
      issues: events.count { |e| e.type == "IssuesEvent" && e.payload.action == "closed" },
      last_commit: last_commit_date(events)
    }
  end

  def calculate_primary_language(repos)
    language_counts = Hash.new(0)  # Create a hash with default value 0
    repos.each do |repo|
      if repo.language  # Ensure the repo has a language
        language_counts[repo.language] += 1  # Count occurrences of each language
      end
    end
    # Find the language with the highest count
    most_common_language = language_counts.max_by { |language, count| count }
    # Return the most common language, or 'None' if there are no languages
    most_common_language ? most_common_language.first : 'None'
  end

  def last_commit_date(events)
    push_events = events.select { |e| e.type == "PushEvent" }
    latest_event = push_events.max_by { |e| e.created_at }
    latest_event&.created_at&.strftime("%Y-%m-%d") || "Never"
  end


  def display_table(stats)
    table = Terminal::Table.new do |t|
      t.title = "#{stats[:username]}'s GitHub Stats"
      t << ["Favourite Language", stats[:primary_language]]
      t << :separator
      t << ["Public Repos", stats[:repos]]
      t << :separator
      t << ["Total Commits", stats[:commits]]
      t << :separator
      t << ["Pull Requests", stats[:prs]]
      t << :separator
      t << ["Issues Closed", stats[:issues]]
      t << :separator
      t << ["Last Commit", stats[:last_commit]]
    end

    puts table
  end

  def generate_midi_song
  end



end
