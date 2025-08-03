module ApiHelpers
  # Signs in a user and extracts the necessary headers for subsequent requests.
  # This is crucial for Devise token-based authentication in API tests.
  def api_sign_in(user)
    # Perform a sign-in request to get the authentication headers.
    post user_session_path, params: {
      user: {
        email: user.email,
        password: user.password
      }
    }
    # Return the headers from the successful sign-in response.
    # The 'Authorization' header is typically used for JWT tokens.
    # Adjust this based on your Devise authentication gem (e.g., 'devise-token-auth' uses different headers).
    response.headers.slice('Authorization')
  end
end