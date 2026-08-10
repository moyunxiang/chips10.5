# frozen_string_literal: true

require_relative '../../lib/congress-api'

class BillsController < ApplicationController
  def index
    @bill_types = Bill.searchable_types
    @results = []
    @total_count = 0
  end

  private

  def congress_client
    api_key = ENV.fetch('CONGRESS_GOV_API_KEY') do
      Rails.application.credentials.congress_gov_api_key
    end
    Congress::API.new(api_key)
  end
end
