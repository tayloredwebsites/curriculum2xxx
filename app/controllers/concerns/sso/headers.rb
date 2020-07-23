module Sso
  module Headers
    def sso_headers(token)
      { 'Authorization' => token }
    end
  end
end
