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

    config.i18n.available_locales = [:en, :tr, :ar_EG, :es]
    config.i18n.default_locale = :en

    # missing translations fallback to en (English))
    config.i18n.fallbacks = {'ar_EG' => 'en', 'tr' => 'en', 'es' => 'en'}
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.assets.precompile << /\.(?:svg|eot|woff|ttf|woff2)$/
  end
end