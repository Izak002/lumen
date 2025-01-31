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

  # Add API emoji
  EMOJIS = {
    info:     "ℹ️ ",
    success:  "✅",
    warning:  "⚠️ ",
    error:    "❌",
    debug:    "🐞",
    api:      "🌐"
  }.freeze

end