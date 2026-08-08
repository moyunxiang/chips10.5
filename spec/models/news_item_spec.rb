# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsItem do
  let(:representative) do
    Representative.create!(name: 'Ada Lovelace', ocdid: '111', title: 'Senator')
  end

  it 'belongs to a representative' do
    news_item = described_class.create!(title: 'Headline', link: 'http://news.test', representative: representative)
    expect(news_item.representative).to eq(representative)
  end

  describe '.find_for' do
    it 'returns a news item for the given representative id' do
      news_item = described_class.create!(title: 'Headline', link: 'http://news.test', representative: representative)
      expect(described_class.find_for(representative.id)).to eq(news_item)
    end

    it 'returns nil when the representative has no news items' do
      expect(described_class.find_for(representative.id)).to be_nil
    end
  end
end
