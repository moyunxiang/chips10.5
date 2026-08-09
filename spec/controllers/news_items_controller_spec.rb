# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsItemsController do
  let(:representative) do
    Representative.create!(name: 'Ada Lovelace', ocdid: '111', title: 'Senator')
  end
  let!(:news_item) do
    NewsItem.create!(title: 'Headline', link: 'http://news.test', representative: representative)
  end

  describe 'GET index' do
    it 'assigns the representative news items' do
      get :index, params: { representative_id: representative.id }
      expect(assigns(:news_items)).to eq([news_item])
    end

    it 'returns a successful response' do
      get :index, params: { representative_id: representative.id }
      expect(response).to be_successful
    end
  end

  describe 'GET show' do
    it 'assigns the requested news item' do
      get :show, params: { representative_id: representative.id, id: news_item.id }
      expect(assigns(:news_item)).to eq(news_item)
    end
  end
end
