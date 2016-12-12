require 'bundler/setup'
require 'dotenv'

Bundler.require :default

ENV['RACK_ENV'] ||= 'development'

Dotenv.load "#{__dir__}/../.env.#{ENV['RACK_ENV']}"

if ENV['RACK_ENV'] != 'production'
  require 'byebug'
end

Dir["#{ __dir__ }/initializers/**/*.rb"].each { |file| require_relative file }