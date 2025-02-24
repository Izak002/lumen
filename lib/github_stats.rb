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

  COLOURS = {
    cyan: "\e[36m",
    green: "\e[32m",
    blue: "\e[34m",
    yellow: "\e[33m",
    magenta: "\e[35m",
    red: "\e[31m",
    light_blue: "\e[94m",
    reset: "\e[0m"
  }.freeze

  def initialize
    @client = Octokit::Client.new(access_token: ACCESS_TOKEN)
    @client.auto_paginate = true
    @user = @client.user
  end

  def display_stats
    stats = fetch_stats
    display_table(stats)
    generate_midi_song(stats)
  end

  def update_readme
    readme_path = "README.md"
    start_marker = "<!-- GITHUB_STATS_START -->"
    end_marker = "<!-- GITHUB_STATS_END -->"
  
    stats = fetch_stats
    return unless stats
  
    table_text = <<~GITHUB_STATS
      ```
      #{Terminal::Table.new do |t|
          t.title = "#{stats[:username]}'s GitHub Stats"
          t.style = { all_separators: true, border: :unicode }
          t << ["Favourite Language", stats[:primary_language]]
          t << ["Public Repos", stats[:repos]]
          t << ["Total Commits", stats[:commits]]
          t << ["Pull Requests", stats[:prs]]
          t << ["Issues Closed", stats[:issues]]
          t << ["Last Commit", stats[:last_commit]]
        end}
      ```
    GITHUB_STATS
  
    content = File.read(readme_path)
  
    if content.include?(start_marker) && content.include?(end_marker)
      new_content = content.gsub(/#{start_marker}.*?#{end_marker}/m, "#{start_marker}\n#{table_text}\n#{end_marker}")
    else
      new_content = "#{content}\n\n#{start_marker}\n#{table_text}\n#{end_marker}"
    end
  
    File.write(readme_path, new_content)
  end
  

  private

  def fetch_stats
    # logger.api_call("Fetching github stats ......")

    repos = @client.repositories(@user.login)
    events = @client.user_events(@user.login)

    push_events = events.select { |event| event.type == "PushEvent" }
    commit_messages = push_events.flat_map do |push_event|
      push_event.payload.commits.map do |commit|
        commit.message
      end
    end
    {
      username: @user.login,
      primary_language: calculate_primary_language(repos),
      commits: events.count { |value| value.type == "PushEvent" },
      commit_messages: commit_messages,
      repos: repos.count { |repo| !repo.fork },
      prs: events.count { |value| value.type == "PullRequestEvent" },
      issues: events.count { |value| value.type == "IssuesEvent" && value.payload.action == "closed" },
      last_commit: last_commit_date(events)
    }
    # logger.success("fetched info successfully :)")
  end

  def calculate_primary_language(repos)
    # logger.debug("Getting primary language ......")
    language_counts = Hash.new(0)  # Create a hash with default value 0
    repos.each do |repo|
      if repo.language  # Ensure the repo has a language
        language_counts[repo.language] += 1  # Count occurrences of each language
      end
    end
    # logger.debug("all languages ...... #{language_counts}")
    # Find the language with the highest count
    most_common_language = language_counts.max_by { |language, count| count }
    # Return the most common language, or 'None' if there are no languages
    most_common_language ? most_common_language.first : 'None'
  end

  def last_commit_date(events)
    # logger.debug("Getting latest commit date ......")
    push_events = events.select { |value| value.type == "PushEvent" }
    latest_event = push_events.max_by { |value| value.created_at }
    latest_event&.created_at&.strftime("%Y-%m-%d") || "Never"
  end


  def display_table(stats)
    table = Terminal::Table.new do |t|
      t.title = apply_colour("#{stats[:username]}'s GitHub Stats", :cyan)
      t << [ apply_colour("Favourite Language", :green), stats[:primary_language] ]
      t << :separator
      t << [ apply_colour("Public Repos", :blue), stats[:repos] ]
      t << :separator
      t << [ apply_colour("Total Commits", :yellow), stats[:commits] ]
      t << :separator
      t << [ apply_colour("Pull Requests", :magenta), stats[:prs] ]
      t << :separator
      t << [ apply_colour("Issues Closed", :red), stats[:issues] ]
      t << :separator
      t << [ apply_colour("Last Commit", :light_blue), stats[:last_commit] ]
    end

    puts table
  end


  def apply_colour(str, colour)
    return str unless COLOURS[colour]
    "#{COLOURS[colour]}#{str}#{COLOURS[:reset]}"
  end

  def generate_midi_song(stats)
    # logger.debug("Generating Song ......")

    seq = MIDI::Sequence.new

    # Create a track for melody
    melody_track = MIDI::Track.new(seq)
    seq.tracks << melody_track
    melody_track.events << MIDI::Tempo.new(MIDI::Tempo.bpm_to_mpq(60))
    melody_track.events << MIDI::MetaEvent.new(MIDI::META_SEQ_NAME, "GitHub Melody")

    # Generate melody from commit messages
    commit_melody = stats[:commit_messages].flat_map { |msg| map_message_to_notes(msg) }
    commit_melody = commit_melody.first(48)

    # Add melody notes
    commit_melody.each do |note|
      melody_track.events << MIDI::NoteOn.new(0, note, 100, 0)
      melody_track.events << MIDI::NoteOff.new(0, note, 100, 120)
    end

    # Create a drum track for rhythm
    drum_track = MIDI::Track.new(seq)
    seq.tracks << drum_track
    drum_track.events << MIDI::MetaEvent.new(MIDI::META_SEQ_NAME, "GitHub Rhythm")

    # Add drum pattern based on PRs & Issues
    drum_pattern = drum_pattern_from_activity(stats[:prs], stats[:issues])
    drum_pattern.each do |note|
      drum_track.events << MIDI::NoteOn.new(9, note, 100, 0)
      drum_track.events << MIDI::NoteOff.new(9, note, 100, 120)
    end

    # Write to file
    File.open("github_song.mid", "wb") { |file| seq.write(file) }
    puts apply_colour("MIDI song 'github_song.mid' generated successfully!", :cyan)
  end

  def map_message_to_notes(message)
    scale = [60, 62, 64, 65, 67, 69, 71, 72] # C Major Scale

    # Extract letters and convert to note values
    message.downcase.chars.select { |char| char.match?(/[a-z]/) } # Only letters
           .map { |char| scale[(char.ord - 'a'.ord) % scale.size] } # Map to scale
  end

  def drum_pattern_from_activity(pr_count, issue_count)
    kick = 36 # Bass drum
    snare = 38 # Snare drum
    hat = 42 # Closed hi-hat

    pattern = []
    (pr_count + issue_count).times do |i|
      pattern << kick if i % 4 == 0
      pattern << snare if i % 4 == 2
      pattern << hat if i.even?
    end
    pattern
  end
end
