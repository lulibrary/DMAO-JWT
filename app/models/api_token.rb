class ApiToken < ActiveRecord::Base

  validates :token, presence: true, uniqueness: true

end