require_relative '../app/jwt_service_application'
require_relative '../app/models/api_token'

class ApiController < JWTServiceApplication

  before do
    validate_api_key
  end

  private

  def validate_api_key
    api_key = get_bearer_token
    halt 404, json({errors: {api_token: "No API key specified in authorization header"}}) unless api_key
    begin
      @api_token = ApiToken.find_by!(token: api_key)
    rescue ActiveRecord::RecordNotFound
      halt 401, json({errors: {api_token: "Invalid API Token"}})
    end
  end

  def get_bearer_token
    pattern = /^Bearer /
    header  = request.env["HTTP_AUTHORIZATION"]
    header.gsub(pattern, '') if header && header.match(pattern)
  end

end