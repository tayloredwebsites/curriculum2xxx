# require simplecov first so everything else is tracked by it.
require 'simplecov'
SimpleCov.start

# Previous content of test helper now starts here
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all
  # Add more helper methods to be used by all tests here...
  include FactoryBot::Syntax::Methods
end
