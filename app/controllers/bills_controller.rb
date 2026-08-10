# frozen_string_literal: true

require_relative '../../lib/congress-api'

class BillsController < ApplicationController
  def index
    @bill_types = Bill.searchable_types
    @congress = params[:congress].presence
    @bill_type = params[:bill_type].presence
    @results = []
    @total_count = 0
    @error = nil

    if @bill_type && @congress.blank?
      @error = 'Please provide a congress session number to search by bill type.'
      return
    end

    perform_search
  end

  private

  def perform_search
    response = congress_client.get(search_path, limit: 50)
    bills = response['bills'] || []
    @results = bills.map { |bill| Bill.from_api(bill) }
    @total_count = response.dig('pagination', 'count') || @results.size
  rescue Congress::APIError => e
    @error = "Could not reach congress.gov: #{e.message}"
  end

  def search_path
    if @congress && @bill_type
      "/bill/#{@congress}/#{@bill_type}"
    elsif @congress
      "/bill/#{@congress}"
    else
      '/bill'
    end
  end

  def congress_client
    api_key = ENV.fetch('CONGRESS_GOV_API_KEY') do
      Rails.application.credentials.congress_gov_api_key
    end
    Congress::API.new(api_key)
  end
end
