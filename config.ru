require 'sinatra/base'
require_relative 'config/environment'
require_relative 'app/jwt_service_application'
require 'raven'

Dir.glob('./api/*.rb').each { |file| require file }

map "/generators" do
  run TokenGeneratorsController
end

map "/" do
  run TokenIssuingController
end

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
end

use Raven::Rack