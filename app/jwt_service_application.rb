require "sinatra/json"
require "sinatra/activerecord"

class JWTServiceApplication < Sinatra::Base

  register Sinatra::ActiveRecordExtension

  configure :production, :development do
    enable :logging
  end

  set :database, {
      adapter: ENV['DB_ADAPTER'],
      pool: ENV.fetch("MAX_THREADS") { 5 }.to_i,
      host: ENV['DB_HOST'],
      username: ENV['DB_USERNAME'],
      password: ENV['DB_PASSWORD'],
      database: ENV['DB_NAME'],
      sslmode: ENV['DB_SSL_MODE'],
      requiressl: ENV['DB_REQUIRE_SSL'],
      sslcert: ENV['DB_SSL_CERT_PATH'],
      sslkey: ENV['DB_SSL_KEY_PATH'],
      sslrootcert: ENV['DB_SSL_ROOT_CERT_PATH']
  }

end