# frozen_string_literal: true

require 'faraday'
require 'json'

# A small wrapper around the congress.gov API (https://api.congress.gov/v3).
#
# Usage:
#   API_KEY = ENV.fetch('CONGRESS_GOV_API_KEY', Rails.application.credentials.congress_gov_api_key)
#   client  = Congress::API.new(API_KEY)
#   client.get('/bill')
#   client.get('/bill', { limit: 100 })
#
# Every request automatically carries the api_key and format=json query params.
module Congress
  # Raised when the congress.gov API returns an error or is unreachable.
  class APIError < StandardError; end

  class API
    BASE_URL = 'https://api.congress.gov/v3'

    def initialize(api_key)
      @api_key = api_key
    end

    # GET a path (e.g. '/bill' or '/bill/118/hr'), returning parsed JSON.
    # Extra query params are merged in on top of api_key/format.
    def get(path, params={})
      response = connection.get(normalize(path), default_params.merge(params))
      raise APIError, "congress.gov responded #{response.status}" unless response.success?

      JSON.parse(response.body)
    rescue Faraday::Error => e
      raise APIError, e.message
    end

    private

    def default_params
      { api_key: @api_key, format: 'json' }
    end

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |conn|
        conn.headers['Accept'] = 'application/json'
        conn.options.timeout = 15
      end
    end

    def normalize(path)
      path.to_s.start_with?('/') ? path.to_s[1..] : path.to_s
    end
  end
end
