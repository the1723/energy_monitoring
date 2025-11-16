source 'https://rubygems.org'

# Core
gem 'rails', '~> 8.1.1'
gem 'propshaft'
gem 'sqlite3', '>= 2.1'
gem 'puma', '>= 5.0'
gem 'jsbundling-rails'
gem 'cssbundling-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]
gem 'bootsnap', require: false

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem 'solid_cache'
gem 'solid_queue'
gem 'solid_cable'

# Deployment
gem 'kamal', require: false
gem 'thruster', require: false

# Application gems
gem 'devise', github: 'heartcombo/devise', branch: 'main'
gem 'basecoat'
gem 'pagy', '~> 43.0'
gem 'groupdate'
gem 'chartkick'

group :development, :test do
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'bundler-audit', require: false
  gem 'brakeman', require: false
  gem 'rubocop-rails-omakase', require: false
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 8.0.2'
  gem 'factory_bot_rails'
  gem 'fuubar'
  gem 'faker'
end

group :development do
  gem 'amazing_print'
  gem 'annotaterb'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'hotwire-spark'
  gem 'letter_opener'
  gem 'web-console'
  gem 'ruby-lsp-rspec', require: false
end

group :test do
  gem 'shoulda-matchers', '~> 6.0'
end
