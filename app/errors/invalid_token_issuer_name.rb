class InvalidTokenIssuerName < StandardError

  def initialize(msg="TOKEN_ISSUER_NAME environment variable is not defined.")
    super(msg)
  end

end