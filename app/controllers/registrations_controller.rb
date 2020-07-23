class RegistrationsController < Devise::RegistrationsController
  include Sso::Registrations
end