require_relative "lib/utils/scriptorium"

logger = Scriptorium.new
logger.should_log?(:debug)