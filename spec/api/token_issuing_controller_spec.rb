require 'spec_helper'
require_relative '../../api/token_issuing_controller'
require_relative '../../app/models/token_generator'
require_relative '../../app/token_issuer'
require_relative '../../app/errors/invalid_token_issuer_name'
require_relative '../../app/errors/invalid_custom_claims_attr'
require_relative '../helpers/api_token_helper'

describe TokenIssuingController do

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

    token = generate_api_token
    token.roles << :issue_tokens
    token.save
    add_api_token_header token.token
  end

  def app
    TokenIssuingController
  end

  it 'returns 403 with error message if token does not have issue tokens role' do

    add_api_header

    attributes = {
        subject: 'testing@test.com'
    }

    post "/#{@generator1.name}/tokens", attributes.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 403, last_response.status

    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["errors"]
    assert parsed_body["errors"]["api_token"]

    assert_equal "You are not able to issue tokens", parsed_body["errors"]["api_token"]

  end

  it 'returns 404 with error message when requesting token from generator that does not exist' do

    attributes = {
        subject: 'testing@test.com'
    }

    post "/idontexist/tokens", attributes.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 404, last_response.status
    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["errors"]
    assert_equal parsed_body["errors"]["token_generator"], "No token generator found with name idontexist"

  end

  it 'returns success response with jwt when requesting token without custom claims' do

    attributes = {
        subject: 'testing@test.com'
    }

    post "/#{@generator1.name}/tokens", attributes.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 200, last_response.status

    assert JSON.parse(last_response.body)["token"]

    token = JSON.parse(last_response.body)["token"]

    decoded_token = JWT.decode token, @generator1.secret, true, { :algorithm => 'HS256' }

    assert decoded_token[0]["sub"]
    assert_equal 'testing@test.com', decoded_token[0]["sub"]

    refute decoded_token[0]["dmao"]

  end

  it 'returns success response with jwt when requesting token with custom claims' do

    attributes = {
        subject: 'testing@test.com',
        custom_claims: {
            test_1: "testing"
        }
    }

    post "/#{@generator1.name}/tokens", attributes.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 200, last_response.status

    assert JSON.parse(last_response.body)["token"]

    token = JSON.parse(last_response.body)["token"]

    decoded_token = JWT.decode token, @generator1.secret, true, { :algorithm => 'HS256' }

    assert decoded_token[0]["sub"]
    assert_equal 'testing@test.com', decoded_token[0]["sub"]

    assert decoded_token[0]["dmao"]
    assert decoded_token[0]["dmao"]["test_1"]
    assert_equal "testing", decoded_token[0]["dmao"]["test_1"]

  end

  it "returns 422 response with error message when subject is not specified" do

    attributes = {}

    post "/#{@generator1.name}/tokens", attributes.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 422, last_response.status

    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["errors"]
    assert parsed_body["errors"]["subject"]
    assert_equal parsed_body["errors"]["subject"], "Subject of token not specified"

  end

  it "returns 500 response when token issuer name is not set server side" do

    attributes = {
        subject: "testing"
    }

    TokenIssuer.expects(:issue).raises(InvalidTokenIssuerName)

    post "/#{@generator1.name}/tokens", attributes.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 500, last_response.status

    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["errors"]
    assert parsed_body["errors"]["message"]

    assert_equal parsed_body["errors"]["message"], "Internal server error generating token"

  end

  it "returns 500 response when custom claims attribute is not set server side" do

    attributes = {
        subject: "testing"
    }

    TokenIssuer.expects(:issue).raises(InvalidCustomClaimsAttr)

    post "/#{@generator1.name}/tokens", attributes.to_json, "CONTENT_TYPE" => "application/json"

    assert_equal 500, last_response.status

    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["errors"]
    assert parsed_body["errors"]["message"]

    assert_equal parsed_body["errors"]["message"], "Internal server error generating token"

  end

end