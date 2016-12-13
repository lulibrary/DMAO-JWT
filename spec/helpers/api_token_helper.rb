require_relative '../../app/models/api_token'

module ApiTokenHelper

  def generate_api_token
    ApiToken.create!(token: SecureRandom.uuid.tr('-', ''))
  end

  def add_api_header
    header 'Authorization', "Bearer #{generate_api_token.token}"
  end

  def add_api_token_header token
    header 'Authorization', "Bearer #{token}"
  end

end