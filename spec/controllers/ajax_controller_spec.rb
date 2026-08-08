# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AjaxController do
  let!(:state) do
    State.create!(name: 'California', symbol: 'CA', fips_code: 6, is_territory: 0,
                  lat_min: 32.30, lat_max: 40.00, long_min: 114.8, long_max: 124.24)
  end
  let!(:county) { state.counties.create!(name: 'Alameda', fips_code: 1, fips_class: 'H1') }

  describe 'GET counties' do
    it 'returns a successful response' do
      get :counties, params: { state_symbol: 'ca' }
      expect(response).to be_successful
    end

    it 'returns the state counties as json' do
      get :counties, params: { state_symbol: 'ca' }
      expect(response.parsed_body.pluck('name')).to include(county.name)
    end
  end
end
