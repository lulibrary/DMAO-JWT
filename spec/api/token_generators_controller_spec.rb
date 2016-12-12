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

end