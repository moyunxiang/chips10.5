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
    raise ArgumentError 'Missing GEOCODIO_API_KEY' if geocodio_api_key.blank?

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
    self.ocdid = official.dig('references', 'govtrack_id') || official['govtrack_id'] if ocdid.blank?
    self.party = official.dig('bio', 'party') || official['party']
    self.address = official.dig('contact', 'address') || official['address']
    self.phone_number = official.dig('contact', 'phone') || official['phone']
    self.website_url = official.dig('contact', 'url') || official['website_url']
    self.photo_url = official.dig('bio', 'photo_url') || official['photo_url']
    save!
    self
  end
end
