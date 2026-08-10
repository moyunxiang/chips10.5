# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BillsController do
  let(:client) { instance_double(Congress::API) }
  let(:api_response) do
    {
      'bills' => [
        { 'title' => 'A Test Bill', 'congress' => 118, 'number' => 123, 'type' => 'HR',
          'originChamber' => 'House',
          'latestAction' => { 'actionDate' => '2024-04-06', 'text' => 'Became Public Law No: 117-108.' } }
      ],
      'pagination' => { 'count' => 250 }
    }
  end

  before { allow(Congress::API).to receive(:new).and_return(client) }

  describe 'GET index' do
    it 'renders the search page' do
      allow(client).to receive(:get).and_return(api_response)
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'shows the 50 most recent bills when no params are given' do
      allow(client).to receive(:get).and_return(api_response)
      get :index
      expect(client).to have_received(:get).with('/bill', hash_including(limit: 50))
      expect(assigns(:results).size).to eq(1)
      expect(assigns(:total_count)).to eq(250)
    end

    it 'queries the congress/type endpoint when both are provided' do
      allow(client).to receive(:get).and_return(api_response)
      get :index, params: { congress: '118', bill_type: 'hr' }
      expect(client).to have_received(:get).with('/bill/118/hr', hash_including(limit: 50))
    end

    it 'refuses to search by bill type without a congress number' do
      get :index, params: { bill_type: 'hr' }
      expect(assigns(:error)).to be_present
      expect(assigns(:results)).to be_empty
      expect(Congress::API).not_to have_received(:new)
    end

    it 'reports a friendly error when the API is unreachable' do
      allow(client).to receive(:get).and_raise(Congress::APIError, 'boom')
      get :index
      expect(assigns(:error)).to include('congress.gov')
      expect(assigns(:results)).to be_empty
    end
  end
end
