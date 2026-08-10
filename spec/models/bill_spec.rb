# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bill do
  it 'does not treat the type column as single-table inheritance' do
    expect(described_class.inheritance_column).to be_blank
  end

  describe '#display_number' do
    it 'formats a House bill as "HR 123"' do
      expect(described_class.new(type: 'hr', number: 123).display_number).to eq('HR 123')
    end

    it 'formats a Senate bill as "S 999"' do
      expect(described_class.new(type: 's', number: 999).display_number).to eq('S 999')
    end
  end

  describe '.searchable_types' do
    it 'includes HR as a [label, value] pair for a dropdown' do
      expect(described_class.searchable_types).to include(%w[HR hr])
    end
  end

  describe '.label_for' do
    it 'maps a known type code to its short label' do
      expect(described_class.label_for('sres')).to eq('SRES')
    end

    it 'falls back to an upcased code when unknown' do
      expect(described_class.label_for('xyz')).to eq('XYZ')
    end
  end

  describe '.from_api' do
    let(:data) do
      { 'title' => 'A Bill', 'congress' => 118, 'number' => 7, 'type' => 'HR',
        'originChamber' => 'House',
        'latestAction' => { 'actionDate' => '2024-04-06', 'text' => 'Became Public Law No: 117-108.' } }
    end

    it 'maps API fields onto a transient Bill' do
      bill = described_class.from_api(data)
      expect(bill.title).to eq('A Bill')
      expect(bill.type).to eq('hr')
      expect(bill.display_number).to eq('HR 7')
    end

    it 'formats the last action with its date' do
      bill = described_class.from_api(data)
      expect(bill.last_action).to eq('Became Public Law No: 117-108. on Apr 6, 2024')
    end
  end

  describe '.format_last_action' do
    it 'returns just the text when there is no date' do
      expect(described_class.format_last_action('Referred to committee', nil))
        .to eq('Referred to committee')
    end

    it 'returns the text unchanged when the date is unparseable' do
      expect(described_class.format_last_action('Something', 'not-a-date')).to eq('Something')
    end
  end

  it 'persists a record whose type column is a bill type, not an STI class' do
    bill = described_class.create!(title: 'A Test Bill', congress: 118, number: 1,
                                   type: 'hr', original_chamber: 'house', summary: 'A summary.')
    expect(bill.reload.type).to eq('hr')
  end
end
