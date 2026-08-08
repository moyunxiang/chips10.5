# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id         :integer          not null, primary key
#  name       :string
#  ocdid      :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Representative < ApplicationRecord
  has_many :news_items, dependent: :delete_all

  # Review the Geocodio docs
  # https://www.geocod.io/docs/#congressional-districts
  def self.geocodio_search(query)
    geocodio_api_key = ENV.fetch('GEOCODIO_API_KEY', Rails.application.credentials[:GEOCODIO_API_KEY])
    raise ArgumentError, 'Missing GEOCODIO_API_KEY' if geocodio_api_key.blank?

    geocodio = Geocodio::Gem.new(geocodio_api_key)
    geocodio.geocode(query, ['cd'])
  end

  # NOTE: This info only grabs data for the most likely represenative district
  # given a search. It would be good to adapt this to show all possible
  # matching representatives for a search / county.
  # See https://www.geocod.io/docs/#data-appends-fields
  def self.civic_api_to_representative_params(rep_info)
    reps = []
    response = rep_info['results'][0]['response']
    fields = response['results'][0]['fields']
    @legislators = fields['congressional_districts'][0]['current_legislators']

    @legislators.each_with_index do |official, _index|
      official['name'] = [official.dig('bio', 'first_name'), official.dig('bio', 'last_name')].compact.join(' ')
      title = official['type']
      # Inspect all the data that's there to make part 1 easier.
      # Rails.logger.debug official
      # official.dig('bio', 'party')
      ocdid = official.dig('references', 'govtrack_id') || official['govtrack_id']
      reps << Representative.find_rep(official, ocdid: ocdid, title: title)
    end
    reps
  end

  def self.find_rep(official, title: '', ocdid: '')
    rep = ocdid.present? ? Representative.find_or_initialize_by(ocdid: ocdid) : Representative.new
    rep.name = official['name'] if official['name'].present?
    rep.title = title
    rep.update_from_geocodio(official)
  end

  def update_from_geocodio(official)
    self.title = official['type'] if official['type'].present?
    self.ocdid = pick(official, %w[references govtrack_id], 'govtrack_id') if ocdid.blank?
    self.party = pick(official, %w[bio party], 'party')
    self.address = pick(official, %w[contact address], 'address')
    self.phone_number = pick(official, %w[contact phone], 'phone')
    self.website_url = pick(official, %w[contact url], 'website_url')
    self.photo_url = pick(official, %w[bio photo_url], 'photo_url')
    save!
    self
  end

  private

  # Read a nested value from the Geocodio hash, falling back to a top-level key.
  def pick(official, dig_path, fallback_key)
    official.dig(*dig_path) || official[fallback_key]
  end
end
