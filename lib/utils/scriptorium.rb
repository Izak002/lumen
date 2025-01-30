require 'logger'

class Scriptorium
  COLORS = {
    debug: "\e[36m",   # Aqua
    info: "\e[32m",    # Green
    warn: "\e[33m",    # Yellow
    error: "\e[31m",   # Red
    fatal: "\e[35m",   # Purple
    reset: "\e[0m"     # Reset color
  }.freeze

  EMOJIS = {
    debug: "🐛",
    info: "ℹ️",
    warn: "⚠️",
    error: "❌",
    fatal: "💀"
  }.freeze
end