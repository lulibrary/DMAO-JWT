class TokenGeneratorSerializer < ActiveModel::Serializer

  attributes :id, :name, :description, :token_ttl, :secret

  def filter(keys)
    if scope.has_role? :view_generator_secret
      keys
    else
      keys - [:secret]
    end
  end

end