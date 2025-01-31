# dependencies -------------------------------------------------------------

require 'fileutils'
require 'date'

# --------------------------------------------------------------------------


class Scriptorium

  COLOURS = {
    reset:       "\e[0m",
    red:         "\e[31m",
    green:       "\e[32m",
    yellow:      "\e[33m",
    blue:        "\e[34m",
    purple:      "\e[35m",
    bright_aqua: "\e[96m"
  }.freeze

  EMOJIS = {
    info:     "ℹ️ ",
    success:  "✅",
    warning:  "⚠️ ",
    error:    "❌",
    debug:    "🐞",
    api:      "🌐"
  }.freeze

  LOG_LEVELS = {
    debug: 0,
    info: 1,
    success: 2,
    warning: 3,
    error: 4
  }.freeze

  def initialize(
    log_file: "log/development.log",
    log_level: :debug
  )
    @log_file = log_file
    @log_level = log_level
    @start_time = Time.now.strftime('%Y-%m-%d %H:%M')

    # creates log directory if it doesnt exist already
    FileUtils.mkdir_p(File.dirname(log_file))
    # creates the file if it doesnt eist
    initialize_log_file
    write_header
  end

  # class methods ------------------------------------------------------


  private

  def initialize_log_file
    # Create empty file if it doesn't exist
    FileUtils.touch(@log_file) unless File.exist?(@log_file)
  end

  def write_header
    # check if the file is empty
    return unless File.zero?(@log_file)
    File.write(@log_file, "# Scriptorium Log - Started #{@start_time}\n", mode: 'w')
  end

  # --------------------------------------------------------------------



end