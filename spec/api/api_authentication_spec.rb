require 'spec_helper'
require_relative '../helpers/test_api_auth_controller'
require_relative '../helpers/api_token_helper'

describe TestApiAuthController do

  include Rack::Test::Methods
  include ApiTokenHelper

  def app
    TestApiAuthController
  end

  it 'returns 401 with errors when no authorization header is specified' do

    get '/'

    assert_equal 401, last_response.status

    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["errors"]
    assert parsed_body["errors"]["api_token"]

    assert_equal "No API key specified in authorization header", parsed_body["errors"]["api_token"]

  end

  it 'returns 403 if api key is specified but not valid' do

    header 'Authorization', "Bearer abcde1234"

    get '/'

    assert_equal 403, last_response.status

    parsed_body = JSON.parse(last_response.body)

    assert parsed_body["errors"]
    assert parsed_body["errors"]["api_token"]

    assert_equal "Invalid API Token", parsed_body["errors"]["api_token"]

  end

  it 'allows any request with a valid token through' do

    add_api_header

    get '/'

    assert_equal 200, last_response.status

  end

end