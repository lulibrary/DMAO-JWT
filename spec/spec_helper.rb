# Require this file for unit tests
ENV['RACK_ENV'] ||= 'test'

require 'simplecov'

SimpleCov.start do
  add_filter "/config/" # Ignore config directory
end

require_relative '../config/environment'
require_relative '../app/jwt_service_application'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'rack/test'
require 'database_cleaner'

DatabaseCleaner.strategy = :transaction

class Minitest::Spec
  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end
end