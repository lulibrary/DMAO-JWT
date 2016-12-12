require 'spec_helper'
require_relative '../../../app/models/token_generator'

describe TokenGenerator do

  before do

    @attributes = {
        name: 'testing',
        description: 'The testing token generator',
        secret: SecureRandom.uuid,
        token_ttl: 3600
    }

    @generator = TokenGenerator.new(@attributes)

  end

  it 'is a valid token generator' do
    assert @generator.valid?
  end

  it 'is invalid without generator name' do
    @generator.name = nil
    refute @generator.valid?
  end

  it 'is invalid without generator secret' do
    @generator.secret = nil
    refute @generator.valid?
  end

  it 'is invalid without generator token ttl' do
    @generator.token_ttl = nil
    refute @generator.valid?
  end

  it 'is invalid for token generator name to have spaces in' do
    @generator.name = 'testing 1234'
    refute @generator.valid?
  end

  it 'is invalid for token generator name to have characters other than A-Z, 0-9 and a-z' do
    @generator.name = 'testing ! $%-'
    refute @generator.valid?
  end

  it 'must have unique token generator name' do
    @generator.save
    generator2 = TokenGenerator.new(@attributes)
    refute generator2.valid?
  end

end