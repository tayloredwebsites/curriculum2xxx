class PasswordsController < Devise::PasswordsController
  include Sso::Headers

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    @user = resource
    if Users::UpdatePasswordService.perform(@user, user_params)
      Rails.logger.debug("Update password was successful".green)
      update_sso_password(@user.email)
      sign_in @user
      redirect_to(root_path, :notice => 'Password was successfully updated.')
    else
      Rails.logger.debug("Update password failed".red)
      redirect_to(change_password_user_path, alert: 'Problem with changing password')
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def update_sso_password(email)
    body = { user: { email: email, password: params[:user][:password] } }
    token = JWT.encode({email: email}, JWT_PASSWORD)
    response = HTTParty.put('http://localhost:3000/users/password', body: body, headers: sso_headers(token)).parsed_response
    response['status']
    Rails.logger.debug("Response - #{response.inspect}".yellow)
  end
end
