module Sso::Sessions

  def create
    if SSO_ENABLED
      user = User.find_by_email(params[:user][:email])
      body = { email: user.email, password: params[:user][:password]}
      response = HTTParty.post('http://localhost:3000/users/sign_in', body: body).parsed_response
      session[:jwt_token] = response['token']
      if user && response['token']
        sign_in user
        respond_with user, location: after_sign_in_path_for(user)
        return
      end
        redirect_to new_user_session_path, alert: "Invalid Credentials"
    else
      super
    end
  end

  def destroy
    if SSO_ENABLED
      jwt_token = session[:jwt_token]
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      if signed_out
        set_flash_message! :notice, :signed_out
        response = HTTParty.delete('http://localhost:3000/users/sign_out', headers: sso_headers(jwt_token)).parsed_response
        session[:jwt_token] = response['token']
      end
      respond_to_on_destroy
    else
      super
    end
  end

  private

  def sso_headers(token)
    { 'Authorization' => token }
  end
end