require 'jwt'
# We also need to require ActiveSupport to get access to 
# HashWithIndifferentAccess and the .hours.from_now method.
require 'active_support/all'

class JsonWebToken
  # The old line: HMAC_SECRET = Rails.application.credentials.devise_jwt_secret_key!
  # Has been replaced with this method.
  def self.secret
    Rails.application.credentials.devise_jwt_secret_key!
  end

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    # The 'sub' claim is essential for Devise-JWT to find the user.
    payload[:sub] = payload[:user_id]
    JWT.encode(payload, secret)
  end

  def self.decode(token)
    # The `secret` method is called here to get the key at runtime.
    body = JWT.decode(token, secret)[0]
    HashWithIndifferentAccess.new body
  rescue JWT::ExpiredSignature, JWT::VerificationError
    nil
  end
end