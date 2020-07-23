class SessionsController < Devise::SessionsController
  include Sso::Sessions
end
