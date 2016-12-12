require 'jwt'
require_relative '../app/models/token_generator'
require_relative '../app/errors/invalid_custom_claims_attr'
require_relative '../app/errors/invalid_token_issuer_name'
require_relative '../app/errors/invalid_token_subject'

class TokenIssuer

  def self.issue token_generator, reserved_claims, custom_claims

    raise InvalidTokenIssuerName if ENV['TOKEN_ISSUER_NAME'].nil? || ENV['TOKEN_ISSUER_NAME'].empty?
    raise InvalidCustomClaimsAttr if ENV['CUSTOM_CLAIMS_ATTR'].nil? || ENV['CUSTOM_CLAIMS_ATTR'].empty?
    raise InvalidTokenSubject if reserved_claims[:sub].nil? || reserved_claims[:sub].empty?

    current_time = Time.now.to_i

    payload = {
        iss: ENV['TOKEN_ISSUER_NAME'],
        sub: reserved_claims[:sub],
        iat: current_time,
        exp: current_time + token_generator.token_ttl,
        aud: token_generator.name,
        jti: SecureRandom.uuid.tr('-', '')
    }

    payload.merge!({ENV['CUSTOM_CLAIMS_ATTR'] => custom_claims}) unless custom_claims.nil? || custom_claims.empty?

    self.generate_token payload, token_generator.secret

  end

  def self.generate_token payload, secret
    JWT.encode payload, secret, 'HS256'
  end

end