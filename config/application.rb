require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Curriculum
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.i18n.available_locales = [:en, :bs, :hr, :sr]
    config.i18n.default_locale = :bs

    # missing translations of hr and sr languages will fallback to bs (Bosnian)
    # missing translations in bs (Bosnian) will fallback to en (English))
    config.i18n.fallbacks = {'hr' => 'bs', 'sr' => 'bs', 'bs' => 'en'}

  end
end
