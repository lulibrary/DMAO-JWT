source 'https://rubygems.org'

gem 'bundler'
gem 'rake'
gem 'sinatra'
gem 'sinatra-contrib'

# ENV Config
gem 'dotenv', '~> 2.0'

# ORM

gem 'pg'
gem 'activerecord'
gem 'sinatra-activerecord'

# Serializers

gem 'sinatra-active-model-serializers'

# JWT

gem 'jwt'

# For role based authorization

gem 'role_model'

group :development, :test do
  gem 'byebug'
end

group :test do
  gem 'minitest'
  gem 'mocha'
  gem 'codeclimate-test-reporter'
  gem 'rack-test'
  gem 'database_cleaner'
end

group :production do
  gem 'puma'
end