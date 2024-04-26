require 'httparty'
require 'base64'

# require 'byebug'

class DukeAPI
  include HTTParty
  base_uri 'prod.apigee.duke-energy.app'

  HEADERS = {
    'Accept': 'application/json, text/plain, */*',
    'Origin': 'https://outagemap.duke-energy.com',
    'Referer': 'https://outagemap.duke-energy.com/',
    'Sec-Fetch-Mode': 'cors',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36'
  }

  def initialize
    keys = Rails.application.credentials.duke
    # they use base64 authentication encoding for security i guess
    auth_token = Base64.strict_encode64(
      "#{keys[:consumer_key_emp]}:#{keys[:consumer_secret_emp]}"
    )

    @headers = HEADERS
    @headers['Authorization'] = "Basic #{auth_token}"
  end

  # fetch outages
  def outages(jurisdiction)
    r = get "/outage-maps/v1/outages?jurisdiction=#{jurisdiction}"

    if r.code == 200
      r.parsed_response
    else show_error r
    end
  end

  private

  def get(path)
    self.class.get path, headers: @headers
  end

  def show_error(request)
    puts "Error #{request.code}: #{request.parsed_response}"
  end
end
