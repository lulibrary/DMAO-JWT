require_relative 'config/environment'
require 'raven'

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
end

use Raven::Rack


require 'sinatra/base'
require_relative 'app/jwt_service_application'

Dir.glob('./api/*.rb').each { |file| require file }

map "/generators" do
  run TokenGeneratorsController
end

map "/" do
  run TokenIssuingController
end