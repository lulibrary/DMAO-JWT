require 'spec_helper'
require_relative '../../api/token_generators_controller'
require_relative '../../app/models/token_generator'
require_relative '../helpers/api_token_helper'

describe TokenGeneratorsController do

  include Rack::Test::Methods
  include ApiTokenHelper

  before do
    @generator1 = TokenGenerator.create!(
        name: 'testing1',
        description: 'Testing generator 1',
        secret: SecureRandom.uuid,
        token_ttl: 3600
    )
    @generator2 = TokenGenerator.create!(
        name: 'testing2',
        description: 'Testing generator 2',
        secret: SecureRandom.uuid,
        token_ttl: 60
    )
  end

  def app
    TokenGeneratorsController
  end

  it 'returns success response when getting list of token generators' do
    add_view_generators_token
    get '/'
    assert_equal 200, last_response.status
  end

  it 'returns list of all token generators' do
    add_view_generators_token
    get '/'
    parsed_body = JSON.parse(last_response.body)
    assert parsed_body["token_generators"]
    assert_equal TokenGenerator.count, parsed_body["token_generators"].length
  end

  it 'returns details of token generator in response' do
    add_view_generators_token
    get '/'
    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["token_generators"]

    generator = parsed_body["token_generators"][0]

    assert_equal generator["id"], @generator1.id
    assert_equal generator["name"], @generator1.name
    assert_equal generator["description"], @generator1.description
    assert_equal generator["token_ttl"], @generator1.token_ttl

    refute generator["secret"]

  end

  it 'returns 404 when token generator cannot be found by id' do
    add_view_generators_token
    get '/0'
    assert_equal 404, last_response.status
  end

  it 'returns error message on 404 response when token generator cannot be found by id' do
    add_view_generators_token
    get '/0'
    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["errors"]
    assert parsed_body["errors"]["token_generator_id"]

    assert_equal parsed_body["errors"]["token_generator_id"], "No token generator found with id 0"
  end

  it 'returns 200 success when getting token generator details' do
    add_view_generators_token
    get "/#{@generator1.id}"
    assert_equal 200, last_response.status
  end

  it "returns details of token generator in response when generator found by id" do
    add_view_generators_token

    get "/#{@generator1.id}"

    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["token_generator"]

    generator = parsed_body["token_generator"]

    assert_equal generator["id"], @generator1.id
    assert_equal generator["name"], @generator1.name
    assert_equal generator["description"], @generator1.description
    assert_equal generator["token_ttl"], @generator1.token_ttl

    refute generator["secret"]

  end

  it 'returns created response when successfully creates a token generator' do

    add_admin_generators_token

    attributes = {
      name: 'testing3',
      description: 'Testing generator 3',
      secret: SecureRandom.uuid,
      token_ttl: 3600
    }

    post '/', attributes.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 201, last_response.status

  end

  it 'returns token generator object when successfully creates a token generator' do

    add_admin_generators_token

    attributes = {
        name: 'testing3',
        description: 'Testing generator 3',
        secret: SecureRandom.uuid,
        token_ttl: 3600
    }

    post '/', attributes.to_json, "CONTENT_TYPE" => "application/json"

    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["token_generator"]

    generator =  parsed_body["token_generator"]

    assert_equal generator["name"], attributes[:name]
    assert_equal generator["description"], attributes[:description]
    assert_equal generator["token_ttl"], attributes[:token_ttl]

    refute generator["secret"]

  end

  it 'returns 422 unprocessable with errors when trying to create generator with existing name' do

    add_admin_generators_token

    attributes = {
        name: 'testing1',
        description: 'Testing generator 1',
        secret: SecureRandom.uuid,
        token_ttl: 3600
    }

    post '/', attributes.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 422, last_response.status

    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["errors"]

    errors =  parsed_body["errors"]

    assert_equal errors.length, 1

    assert errors["name"]

    assert_equal errors["name"][0], "has already been taken"

  end

  it "returns 404 when generator id cannot be found for update" do
    add_admin_generators_token
    patch '/0'
    assert_equal 404, last_response.status
  end

  it "returns 404 with error object when generator id cannot be found for update" do
    add_admin_generators_token
    patch '/0'
    parsed_body = JSON.parse(last_response.body)
    error_object = {"token_generator_id" => "No token generator found with id 0"}
    assert_equal error_object, parsed_body["errors"]
  end

  it "returns 422 unprocessable when invalid or empty attributes for token generator update" do

    add_admin_generators_token

    update_attributes = {
        invalid_key: "testing"
    }

    patch "/#{@generator1.id}", update_attributes.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 422, last_response.status

  end

  it "returns error message when invalid or empty attributes for token generator update" do

    add_admin_generators_token

    update_attributes = {
        invalid_key: "testing"
    }

    error_object = {"message"=>"No data specified to update token generator with you can only update the following attributes [\"description\", \"token_ttl\", \"secret\"]"}

    patch "/#{@generator1.id}", update_attributes.to_json, "CONTENT_TYPE" => "application/json"

    parsed_body = JSON.parse(last_response.body)

    assert_equal error_object, parsed_body["errors"]

  end

  it "returns 422 unprocessable with error message when unable to update token generator" do

    add_admin_generators_token

    update_attributes = {
        description: 'Testing Generator 1 updated'
    }

    TokenGenerator.any_instance.expects(:update).once.returns(false)

    patch "/#{@generator1.id}", update_attributes.to_json, "CONTENT_TYPE" => "application/json"

    parsed_body = JSON.parse(last_response.body)

    assert_equal 422, last_response.status
    assert parsed_body["errors"]

  end

  it "returns 200 okay with token generator when successfully updating a token generator" do

    add_admin_generators_token

    update_attributes = {
        description: 'Token Generator 1 updated'
    }

    patch "/#{@generator1.id}", update_attributes.to_json, "CONTENT_TYPE" => "application/json"

    parsed_body = JSON.parse(last_response.body)

    assert_equal 200, last_response.status
    assert parsed_body["token_generator"]

    assert_equal 'Token Generator 1 updated', parsed_body["token_generator"]["description"]

  end

  it "returns 404 when generator id cannot be found for delete" do
    add_admin_generators_token
    delete '/0'
    assert_equal 404, last_response.status
  end

  it "returns 200 when generator with id has successfully been deleted" do
    add_admin_generators_token
    delete "/#{@generator1.id}"
    assert_equal 200, last_response.status
  end

  it "returns empty response when generator with id has successfully been deleted" do
    add_admin_generators_token
    delete "/#{@generator1.id}"
    assert_equal JSON.parse(last_response.body), ""
  end

  it "returns unprocessable when destroy fails" do
    add_admin_generators_token
    TokenGenerator.any_instance.expects(:destroy).once.returns(false)
    delete "/#{@generator1.id}"
    assert_equal 422, last_response.status
  end

  it "returns error message when error deleting system" do

    add_admin_generators_token

    TokenGenerator.any_instance.expects(:destroy).once.returns(false)

    delete "/#{@generator1.id}"

    parsed_body = JSON.parse last_response.body

    assert parsed_body["errors"]

    assert_equal parsed_body["errors"].length, 1

    assert parsed_body["errors"]["token_generator"]

    assert_equal parsed_body["errors"]["token_generator"], "Error deleting token generator with id #{@generator1.id}"

  end

  private

  def add_view_generators_token
    token = generate_api_token
    token.roles << :view_generator_details
    token.save
    add_api_token_header token.token
  end

  def add_admin_generators_token
    token = generate_api_token
    token.roles << :admin_generators
    token.save
    add_api_token_header token.token
  end

end