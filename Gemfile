source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# MariaDB (compatible con mysql2)
gem "mysql2", "~> 0.5"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.4"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Authentication and authorization 
gem "devise", "~> 4.9"
gem "devise-jwt", "~> 0.11"

# React (CORS) support for Rails API applications
gem "rack-cors"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# To load environment variables
gem "dotenv-rails"

group :development, :test do
  # Debug in console
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Linter
  gem "rubocop-rails-omakase", require: false

  # Security scanner
  gem "brakeman", require: false

  # Framework de testing
  gem "rspec-rails"

  # Factories y test data generator
  gem "factory_bot_rails"
  gem "faker"
  gem 'shoulda-matchers'

  # Add the pry gems
  gem 'pry'
  gem 'pry-byebug'
end
