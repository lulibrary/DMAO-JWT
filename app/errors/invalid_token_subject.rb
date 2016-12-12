class InvalidTokenSubject < StandardError

  def initialize(msg="Token subject is not defined in reserved claims")
    super(msg)
  end

end