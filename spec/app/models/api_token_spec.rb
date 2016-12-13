require 'spec_helper'
require_relative '../../../app/models/api_token'

describe ApiToken do

  before do
    attributes = {
        token: SecureRandom.uuid.tr('-', '')
    }
    @token = ApiToken.new(attributes)
  end

  it 'is a valid api token' do
    assert @token.valid?
  end

  it 'does not allow creating an api token with the same token value' do
    @token.save
    token2 = ApiToken.new(token: @token.token)
    refute token2.valid?
  end

end