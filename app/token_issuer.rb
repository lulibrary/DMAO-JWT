require 'jwt'
require_relative '../app/models/token_generator'
require_relative '../app/errors/invalid_custom_claims_attr'
require_relative '../app/errors/invalid_token_issuer_name'
require_relative '../app/errors/invalid_token_subject'

class TokenIssuer

  def self.issue token_generator, reserved_claims, custom_claims, token_ttl
    issuer = TokenIssuer.new
    issuer.issue_token token_generator, reserved_claims, custom_claims, token_ttl
  end

  def issue_token token_generator, reserved_claims, custom_claims, token_ttl

    validate_token_issuer_name
    validate_custom_claims_attr

    raise InvalidTokenSubject if reserved_claims[:sub].nil? || reserved_claims[:sub].empty?

    token_ttl = token_ttl.nil? || token_ttl.empty? ? token_generator.token_ttl: token_ttl

    payload = generate_common_payload reserved_claims[:sub], token_generator.name, token_ttl

    payload = merge_custom_claims payload, custom_claims

    generate_token payload, token_generator.secret

  end

  private

  def validate_token_issuer_name
    raise InvalidTokenIssuerName if ENV['TOKEN_ISSUER_NAME'].nil? || ENV['TOKEN_ISSUER_NAME'].empty?
  end

  def validate_custom_claims_attr
    raise InvalidCustomClaimsAttr if ENV['CUSTOM_CLAIMS_ATTR'].nil? || ENV['CUSTOM_CLAIMS_ATTR'].empty?
  end

  def generate_token payload, secret
    JWT.encode payload, secret, 'HS256'
  end

  def generate_common_payload subject, audience, token_ttl

    current_time = Time.now.to_i

    {
        iss: ENV['TOKEN_ISSUER_NAME'],
        sub: subject,
        iat: current_time,
        exp: current_time + token_ttl,
        aud: audience,
        jti: SecureRandom.uuid.tr('-', '')
    }

  end

  def merge_custom_claims payload, custom_claims

    if custom_claims.nil? || custom_claims.empty?
      payload
    else
      payload.merge({ENV['CUSTOM_CLAIMS_ATTR'] => custom_claims})
    end

  end

end