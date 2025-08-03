RSpec.configure do |config|
  # ... other configurations ...
  

  # Require the JWT helper from app/lib
  require Rails.root.join('app/lib/json_web_token')

  # Helper method to parse the JSON response body
  def json_response
    JSON.parse(response.body)
  end
end