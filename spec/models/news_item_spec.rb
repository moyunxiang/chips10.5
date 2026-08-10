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

  describe '.issues' do
    it 'returns the fixed list of political issues' do
      expect(described_class.issues).to include('Climate Change', 'Immigration', 'Equal Pay')
    end

    it 'has 17 issues' do
      expect(described_class.issues.length).to eq(17)
    end

    it 'is frozen so callers cannot mutate the canonical list' do
      expect(described_class.issues).to be_frozen
    end
  end

  it 'persists an associated issue' do
    news_item = described_class.create!(title: 'Headline', link: 'http://news.test',
                                        representative: representative, issue: 'Climate Change')
    expect(news_item.reload.issue).to eq('Climate Change')
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
