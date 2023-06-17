require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PrtimesScraping
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    ## 定期実行(whenever)で必要なため追加
    config.autoload_paths += Dir["#{config.root}/lib"]
    config.enable_dependency_loading = true
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.paths.add 'lib', eager_load: true
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
  end
end
