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

  post '/' do

    data = request_data

    attributes = {
        name: data["name"],
        description: data["description"],
        secret: data["secret"],
        token_ttl: data["token_ttl"]
    }

    generator = TokenGenerator.new attributes

    if generator.save
      status 201
      json generator
    else
      status 422
      error_response = {errors: generator.errors}
      json error_response
    end

  end

  patch '/:id' do

    begin
      generator = TokenGenerator.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      halt 404, json({errors: {token_generator_id: "No token generator found with id #{params[:id]}"}})
    end

    data = request_data

    valid_update_keys = ["description", "token_ttl", "secret"]

    data.keep_if { |k, _v| valid_update_keys.include? k }

    if data.nil? || data.empty?
      halt 422, json({errors: {message: "No data specified to update token generator with you can only update the following attributes #{valid_update_keys}"}})
    end

    if generator.update data
      status 200
      json generator
    else
      status 422
      error_response = {errors: generator.errors}
      json error_response
    end

  end

  delete '/:id' do

    begin
      generator = TokenGenerator.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      halt 404, json({errors: {token_generator_id: "No token generator found with id #{params[:id]}"}})
    end

    if generator.destroy
      status 200
      json ""
    else
      status 422
      error_response = {errors: {token_generator: "Error deleting token generator with id #{params[:id]}"}}
      json error_response
    end

  end

  private

  def request_data

    request.body.rewind
    JSON.parse request.body.read

  end

end