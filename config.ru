require 'sinatra/base'
require_relative 'config/environment'
require_relative 'app/jwt_service_application'

Dir.glob('./api/*.rb').each { |file| require file }