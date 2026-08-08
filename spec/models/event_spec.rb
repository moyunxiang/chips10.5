# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  let(:state) do
    State.create!(name: 'California', symbol: 'CA', fips_code: 6, is_territory: 0,
                  lat_min: 32.30, lat_max: 40.00, long_min: 114.8, long_max: 124.24)
  end
  let(:county) { state.counties.create!(name: 'Alameda', fips_code: 1, fips_class: 'H1') }

  def build_event(attrs={})
    Event.new({ name: 'Town Hall', county: county,
                start_time: 1.day.from_now, end_time: 2.days.from_now }.merge(attrs))
  end

  it 'is valid with future start and end times' do
    expect(build_event).to be_valid
  end

  it 'requires a start and end time' do
    expect(build_event(start_time: nil, end_time: nil)).not_to be_valid
  end

  it 'rejects an end time before the start time' do
    expect(build_event(start_time: 2.days.from_now, end_time: 1.day.from_now)).not_to be_valid
  end

  it 'delegates state to its county' do
    expect(build_event.state).to eq(state)
  end

  it 'maps county names to ids for its state' do
    expect(build_event.county_names_by_id).to eq({ 'Alameda' => county.id })
  end
end
