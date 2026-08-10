# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BillsController do
  describe 'GET index' do
    it 'renders the bills search page' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'exposes the searchable bill types to the view' do
      get :index
      expect(assigns(:bill_types)).to include(%w[HR hr])
    end
  end
end
