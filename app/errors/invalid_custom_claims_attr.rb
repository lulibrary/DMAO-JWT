class InvalidCustomClaimsAttr < StandardError

  def initialize(msg="CUSTOM_CLAIMS_ATTR environment variable is not defined.")
    super(msg)
  end

end