module UserSystemHelper

  puts "loaded UserSystemHelper"
  # for use in system tests
  def system_sign_in user, passwd=nil
    passwd ||= user.password
    page.find("#topNav a[href='/users/sign_in']").click
    # page.find("#main-container form input[name='user[email]']").set(user.email)
    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: passwd
    click_button "Log in"
  end

end
