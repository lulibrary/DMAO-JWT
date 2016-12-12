require_relative 'api_controller'
require_relative '../app/models/token_generator'

class TokenGeneratorsController < ApiController

  get '/' do

    generators = TokenGenerator.all

    status 200
    json generators, { root: 'token_generators' }

  end

end