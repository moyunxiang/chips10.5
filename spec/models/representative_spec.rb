# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id         :integer          not null, primary key
#  city       :string
#  name       :string
#  ocdid      :string
#  party      :string
#  photo_url  :string
#  state      :string
#  street     :string
#  title      :string
#  zip        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

# This file is a stub.
# You should add your own test cases.
# We recommend creating a file for each model in the database.

RSpec.describe Representative do
  describe '.find_rep' do
    let(:official) do
      {
        'name' => 'Ada Lovelace',
        'type' => 'representative',
        'bio' => { 'party' => 'Independent', 'photo_url' => 'https://example.test/ada.jpg' },
        'contact' => { 'address' => '1 Main Street', 'phone' => '555-0100', 'url' => 'https://example.test' },
        'references' => { 'govtrack_id' => '12345' }
      }
    end

    it 'updates an existing representative instead of creating a duplicate' do
      existing = described_class.create!(name: 'Old Name', ocdid: '12345')
      rep = described_class.find_rep(official, title: 'representative', ocdid: '12345')

      expect(rep).to eq(existing)
      expect(described_class.where(ocdid: '12345').count).to eq(1)
      expect(rep).to have_attributes(name: 'Ada Lovelace', party: 'Independent', phone_number: '555-0100')
    end
  end
end
