# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchController do
  describe 'GET search' do
    let(:geocodio_response) do
      legislator = {
        'type' => 'representative',
        'bio' => { 'first_name' => 'Ada', 'last_name' => 'Lovelace', 'party' => 'Independent' },
        'contact' => { 'address' => '1 Main Street', 'phone' => '555-0100', 'url' => 'https://example.test' },
        'references' => { 'govtrack_id' => '412345' }
      }
      { 'results' => [{ 'response' => { 'results' => [{ 'fields' => {
        'congressional_districts' => [{ 'current_legislators' => [legislator] }]
      } }] } }] }
    end

    before do
      allow(Representative).to receive(:geocodio_search).and_return(geocodio_response)
    end

    it 'assigns representatives built from the search' do
      get :search, params: { address: '1 Main Street' }
      expect(assigns(:representatives).first.name).to eq('Ada Lovelace')
    end

    it 'assigns the search term' do
      get :search, params: { address: '1 Main Street' }
      expect(assigns(:search_term)).to eq('1 Main Street')
    end
  end
end
