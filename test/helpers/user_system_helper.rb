module UserSystemHelper

  # for use in system tests
  def sign_in user, passwd=nil
    passwd ||= user.password
    visit root_path
    fill_in "Username", with: user.username
    fill_in "Password", with: passwd
    click_button "Log in"
  end

end
