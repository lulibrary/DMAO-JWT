require_relative 'api_controller'
require_relative '../app/models/token_generator'
require_relative '../app/token_issuer'

class TokenIssuingController < ApiController

  post '/:name/tokens' do

    halt 403, json({errors: {api_token: "You are not able to issue tokens"}}) unless @api_token.has_role? :issue_tokens

    begin
      generator = TokenGenerator.find_by!(name: params[:name])
      data = request_data
      token = TokenIssuer.issue generator, {sub: data["subject"]}, data["custom_claims"], data["token_ttl"]
    rescue ActiveRecord::RecordNotFound
      halt 404, json({errors: {token_generator: "No token generator found with name #{params[:name]}"}})
    rescue InvalidTokenIssuerName, InvalidCustomClaimsAttr
      halt 500, json({errors: {message: "Internal server error generating token"}})
    rescue InvalidTokenSubject
      halt 422, json({errors: {subject: "Subject of token not specified"}})
    end

    status 200
    response = {
        token: token
    }
    json response

  end

  private

  def request_data

    request.body.rewind
    JSON.parse request.body.read

  end

end