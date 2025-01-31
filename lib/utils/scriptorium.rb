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

  # Logging methods ----------------------------------------------------
  def debug(message)
    log(:debug, "DEBUG", message, COLOURS[:gray]) if should_log?(:debug)
  end

  def info(message)
    log(:info, "INFO", message, COLOURS[:blue]) if should_log?(:info)
  end

  def success(message)
    log(:success, "SUCCESS", message, COLOURS[:green]) if should_log?(:success)
  end

  def warning(message)
    log(:warning, "WARNING", message, COLOURS[:yellow]) if should_log?(:warning)
  end

  def error(message)
    log(:error, "ERROR", message, COLOURS[:red]) if should_log?(:error)
  end

  def api_call(message)
    log(:api, "API", message, COLOURS[:bright_aqua]) if should_log?(:info)
  end

  # -----------------------------------------------------------------------

  private

  def should_log?(level)
    LOG_LEVELS[level] >= LOG_LEVELS[@log_level]
  end

  def log(level, label, message, color)
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M")
    entry = "#{timestamp} #{EMOJIS[level]} [#{label}] #{message}"
    # Console output
    puts "#{color}#{entry}#{COLOURS[:reset]}"
    # File output
    File.open(@log_file, "a") do |log_file|
      log_file.puts(entry)
    end
  end

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