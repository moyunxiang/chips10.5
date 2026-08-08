# frozen_string_literal: true

# == Schema Information
#
# Table name: counties
#
#  id         :integer          not null, primary key
#  fips_class :string(2)        not null
#  fips_code  :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_id   :integer          not null
#
# Indexes
#
#  index_counties_on_state_id  (state_id)
#
class County < ApplicationRecord
  belongs_to :state

  # Seed data stores full names like "Alameda County"; the app expects the bare
  # name ("Alameda") and adds the "County" suffix in views/queries as needed.
  before_validation :strip_type_suffix

  # Standardized FIPS code eg. 001 for 1.
  def std_fips_code
    fips_code.to_s.rjust(3, '0')
  end

  private

  def strip_type_suffix
    return if name.blank?

    self.name = name.sub(/\s+(County|Parish|Borough|Census Area|Municipality)\z/, '')
  end
end
