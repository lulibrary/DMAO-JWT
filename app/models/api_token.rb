require 'role_model'

class ApiToken < ActiveRecord::Base

  include RoleModel

  roles :view_generator_details, :view_generator_secret

  validates :token, presence: true, uniqueness: true

end