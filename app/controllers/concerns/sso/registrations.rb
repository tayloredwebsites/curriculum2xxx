module Sso
  module Registrations

    include Sso::Constants

    def create
      build_resource(sign_up_params)
      resource.save
      if resource.persisted?
        perform_sso_signup if secrets['sso_enabled']

        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end

    def perform_sso_signup
      body = {user: sign_up_params}
      response = HTTParty.post(secrets['sso_url'] + '/users', body: body).parsed_response
      session[:jwt_token] = response['token']
    end
  end
end