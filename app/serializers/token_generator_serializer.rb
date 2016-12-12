class TokenGeneratorSerializer < ActiveModel::Serializer

  attributes :id, :name, :description, :token_ttl

end