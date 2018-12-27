
# to output Rails.logger statements to console during tests:
Rails.logger = ActiveSupport::Logger.new(STDOUT)
# logger.log_level = :debug
Rails.logger.formatter = ::Logger::Formatter.new
Rails.logger.debug "---     Testing      ---"
