require 'spec_helper'
require_relative '../../api/token_generators_controller'
require_relative '../../app/models/token_generator'

describe TokenGeneratorsController do

  include Rack::Test::Methods

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
    get '/'
    assert_equal 200, last_response.status
  end

  it 'returns list of all token generators' do
    get '/'
    parsed_body = JSON.parse(last_response.body)
    assert parsed_body["token_generators"]
    assert_equal TokenGenerator.count, parsed_body["token_generators"].length
  end

  it 'returns details of token generator in response' do

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
    get '/0'
    assert_equal 404, last_response.status
  end

  it 'returns error message on 404 response when token generator cannot be found by id' do
    get '/0'
    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["errors"]
    assert parsed_body["errors"]["token_generator_id"]

    assert_equal parsed_body["errors"]["token_generator_id"], "No token generator found with id 0"
  end

  it 'returns 200 success when getting token generator details' do
    get "/#{@generator1.id}"
    assert_equal 200, last_response.status
  end

  it "returns details of token generator in response when generator found by id" do

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

end