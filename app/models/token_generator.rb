class TokenGenerator < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9]+\Z/ }

  validates :secret, presence: true

  validates :token_ttl, presence: true

end