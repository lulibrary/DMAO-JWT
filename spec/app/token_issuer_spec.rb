require 'spec_helper'
require_relative '../../app/models/token_generator'
require_relative '../../app/token_issuer'

describe TokenIssuer do

  before do
    @generator = TokenGenerator.create!(
        name: 'testing1',
        description: 'Testing generator 1',
        secret: 'abcdefg',
        token_ttl: 120
    )
  end

  it 'has an issue method defined' do
    assert_respond_to TokenIssuer, :issue
  end

  it 'should raise invalid token issuer name if token issuer name env is blank' do

    previous_env_value = ENV['TOKEN_ISSUER_NAME']

    ENV['TOKEN_ISSUER_NAME'] = ""

    assert_raises "InvalidTokenIssuerName" do
      TokenGenerator.issue @generator, {}, {}, nil
    end

    ENV['TOKEN_ISSUER_NAME'] = previous_env_value

  end

  it 'should raise invalid custom claims attr if custom claims attr env is blank' do

    previous_env_value = ENV['CUSTOM_CLAIMS_ATTR']

    ENV['CUSTOM_CLAIMS_ATTR'] = ""

    assert_raises "InvalidCustomClaimsAttr" do
      TokenGenerator.issue @generator, {}, {}, nil
    end

    ENV['CUSTOM_CLAIMS_ATTR'] = previous_env_value

  end

  it 'should raise invalid token subject error if sub is not defined in reserved claims' do

    assert_raises "InvalidTokenSubject" do
      TokenGenerator.issue @generator, {}, {}, nil
    end

  end

  it 'call issue token on instance of token issuer' do

    TokenIssuer.any_instance.expects(:issue_token).once

    TokenIssuer.issue @generator, {}, {}, nil

  end

  it 'calls generate token with no custom claims in payload when they are empty' do

    Time.expects(:now).at_least_once.returns('123456')
    SecureRandom.expects(:uuid).at_least_once.returns('abcd1234')

    payload = {
        iss: 'dmao_jwt',
        sub: 'test',
        iat: 123456,
        exp: 123576,
        aud: 'testing1',
        jti: 'abcd1234'
    }

    TokenIssuer.any_instance.expects(:generate_token).with(payload, 'abcdefg').once

    TokenIssuer.issue @generator, {sub: 'test'}, {}, nil

  end

  it 'calls generate token with no custom claims in payload when they are nil' do

    Time.expects(:now).at_least_once.returns('123456')
    SecureRandom.expects(:uuid).at_least_once.returns('abcd1234')

    payload = {
        iss: 'dmao_jwt',
        sub: 'test',
        iat: 123456,
        exp: 123576,
        aud: 'testing1',
        jti: 'abcd1234'
    }

    TokenIssuer.any_instance.expects(:generate_token).with(payload, 'abcdefg').once

    TokenIssuer.issue @generator, {sub: 'test'}, nil, nil

  end

  it 'merges custom claims into payload when they are specified' do

    Time.expects(:now).at_least_once.returns('123456')
    SecureRandom.expects(:uuid).at_least_once.returns('abcd1234')

    payload = {
        iss: 'dmao_jwt',
        sub: 'test',
        iat: 123456,
        exp: 123576,
        aud: 'testing1',
        jti: 'abcd1234',
        ENV['CUSTOM_CLAIMS_ATTR'] => {
            'test': 'test value'
        }
    }

    TokenIssuer.any_instance.expects(:generate_token).with(payload, 'abcdefg').once

    TokenIssuer.issue @generator, {sub: 'test'}, {'test': 'test value'}, nil

  end

  it 'should call jwt encode with payload, secret and algorithm set to HS256' do

    Time.expects(:now).at_least_once.returns('123456')
    SecureRandom.expects(:uuid).at_least_once.returns('abcd1234')

    payload = {
        iss: 'dmao_jwt',
        sub: 'test',
        iat: 123456,
        exp: 123576,
        aud: 'testing1',
        jti: 'abcd1234',
        ENV['CUSTOM_CLAIMS_ATTR'] => {
            'test': 'test value'
        }
    }

    JWT.expects(:encode).once.with(payload, 'abcdefg', 'HS256')

    TokenIssuer.issue @generator, {sub: 'test'}, {'test': 'test value'}, nil

  end

  it 'should strip dashes from secure random uuid' do

    Time.expects(:now).at_least_once.returns('123456')
    SecureRandom.expects(:uuid).at_least_once.returns('abcd-1234')

    payload = {
        iss: 'dmao_jwt',
        sub: 'test',
        iat: 123456,
        exp: 123576,
        aud: 'testing1',
        jti: 'abcd1234',
        ENV['CUSTOM_CLAIMS_ATTR'] => {
            'test': 'test value'
        }
    }

    JWT.expects(:encode).once.with(payload, 'abcdefg', 'HS256')

    TokenIssuer.issue @generator, {sub: 'test'}, {'test': 'test value'}, nil

  end

end