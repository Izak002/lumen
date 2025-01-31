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

  # testing log levels for myself
  def should_log?(message_level)
     if LOG_LEVELS[message_level] >= LOG_LEVELS[:warning]
      puts "yes"
     end
  end

end