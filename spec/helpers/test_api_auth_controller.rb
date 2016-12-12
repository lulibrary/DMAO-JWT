require_relative '../../api/api_controller'

class TestApiAuthController < ApiController

  get '/' do
    status 200
    json "Success"
  end

end