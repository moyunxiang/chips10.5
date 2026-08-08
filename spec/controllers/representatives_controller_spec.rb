# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepresentativesController do
  describe 'GET show' do
    let(:representative) do
      Representative.create!(
        name: 'Ada Lovelace',
        ocdid: '12345',
        title: 'Representative',
        party: 'Independent',
        address: '1 Main Street',
        phone_number: '555-0100',
        website_url: 'https://example.test',
        photo_url: 'https://example.test/ada.jpg'
      )
    end

    it 'loads the requested representative profile' do
      get :show, params: { id: representative.id }

      expect(response).to be_successful
      expect(assigns(:representative)).to eq(representative)
    end
  end
end
