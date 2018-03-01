# require simplecov first so everything else is tracked by it.
require 'simplecov'
SimpleCov.start
# end simplecov

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'logger'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all
  # Add more helper methods to be used by all tests here...
  include FactoryBot::Syntax::Methods
end

# # to output Rails.logger statements to console during tests:
# Rails.logger = ActiveSupport::Logger.new(STDOUT)
# # logger.log_level = :debug
# Rails.logger.formatter = ::Logger::Formatter.new
# Rails.logger.debug "---     Testing      ---"
