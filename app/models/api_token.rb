require 'role_model'

class ApiToken < ActiveRecord::Base

  include RoleModel

  roles :view_generator_details, :view_generator_secret, :admin_generators, :issue_tokens

  validates :token, presence: true, uniqueness: true

end