require_relative 'api_controller'
require_relative '../app/models/token_generator'

class TokenGeneratorsController < ApiController

  get '/' do

    halt 403, json({errors: {api_token: "You are not able to issue tokens"}}) unless @api_token.has_role? :view_generator_details

    generators = TokenGenerator.all

    status 200
    json generators, { root: 'token_generators' }

  end

  get '/:id' do

    halt 403, json({errors: {api_token: "You are not able to issue tokens"}}) unless @api_token.has_role? :view_generator_details

    generator = find_generator_or_error params[:id]

    status 200
    json generator

  end

  post '/' do

    halt 403, json({errors: {api_token: "You are not able to issue tokens"}}) unless @api_token.has_role? :admin_generators

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

    halt 403, json({errors: {api_token: "You are not able to issue tokens"}}) unless @api_token.has_role? :admin_generators

    generator = find_generator_or_error params[:id]

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

    halt 403, json({errors: {api_token: "You are not able to issue tokens"}}) unless @api_token.has_role? :admin_generators

    generator = find_generator_or_error params[:id]

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

  def find_generator_or_error id
    begin
      TokenGenerator.find(id)
    rescue ActiveRecord::RecordNotFound
      halt 404, json({errors: {token_generator_id: "No token generator found with id #{id}"}})
    end
  end

  def request_data

    request.body.rewind
    JSON.parse request.body.read

  end

end