# frozen_string_literal: true

# == Schema Information
#
# Table name: bills
#
#  id               :integer          not null, primary key
#  congress         :integer
#  number           :integer
#  original_chamber :string
#  summary          :text
#  title            :string
#  type             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Bill < ApplicationRecord
  # `type` is a real bill attribute (HR, S, ...), not Rails single-table
  # inheritance, so disable STI on this column.
  self.inheritance_column = nil

  # Short chamber prefixes used when rendering a bill number like "HR 123".
  # Keys are the congress.gov bill "type" codes.
  TYPE_LABELS = {
    'hr' => 'HR', 'hres' => 'HRES', 'hjres' => 'HJRES', 'hconres' => 'HCONRES',
    's' => 'S', 'sres' => 'SRES', 'sjres' => 'SJRES', 'sconres' => 'SCONRES'
  }.freeze

  # The bill types a user may search by, as [label, value] pairs for a dropdown.
  def self.searchable_types
    TYPE_LABELS.map { |code, label| [label, code] }
  end

  # e.g. "HR 123" — the short type label followed by the bill number.
  def display_number
    "#{self.class.label_for(type)} #{number}".strip
  end

  def self.label_for(type_code)
    TYPE_LABELS.fetch(type_code.to_s.downcase, type_code.to_s.upcase)
  end
end
