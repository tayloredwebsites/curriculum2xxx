require 'test_helper'
require 'application_system_test_case'
SimpleCov.command_name "system_set"

module UserSystemHelper

  puts "loaded UserSystemHelper"
  # for use in system tests
  def system_sign_in user, passwd=nil, locale='en'
    passwd ||= user.password
    page.find("#topNav a[href='/#{locale}/users/sign_in']").click
    # page.find("#main-container form input[name='user[email]']").set(user.email)
    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: passwd
    click_button "Log in"
  end

end

module FixLocales
  module ::ActionController::TestCase::Behavior
    alias_method :process_without_logging, :process

    puts "loaded FixLocales"

    def process(action, http_method = 'GET', *args)
      puts "FixLocales Process"
      e = Array.wrap(args).compact
      e[0] ||= {}
      e[0].merge!({locale: I18n.locale})
      process_without_logging(action, http_method, *e)
    end
  end
end
