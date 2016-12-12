require_relative 'api_controller'
require_relative '../app/models/token_generator'

class TokenGeneratorsController < ApiController

  get '/' do

    generators = TokenGenerator.all

    status 200
    json generators, { root: 'token_generators' }

  end

  get '/:id' do

    begin
      generator = TokenGenerator.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      halt 404, json({errors: {token_generator_id: "No token generator found with id #{params[:id]}"}})
    end

    status 200
    json generator

  end

end