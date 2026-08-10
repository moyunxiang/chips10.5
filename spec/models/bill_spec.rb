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

  it 'persists a record whose type column is a bill type, not an STI class' do
    bill = described_class.create!(title: 'A Test Bill', congress: 118, number: 1,
                                   type: 'hr', original_chamber: 'house', summary: 'A summary.')
    expect(bill.reload.type).to eq('hr')
  end
end
