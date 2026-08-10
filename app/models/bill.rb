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

  # Transient fields used only when displaying congress.gov search results
  # (they are not persisted columns).
  attr_accessor :last_action

  # The bill types a user may search by, as [label, value] pairs for a dropdown.
  def self.searchable_types
    TYPE_LABELS.map { |code, label| [label, code] }
  end

  # Builds a non-persisted Bill from a congress.gov API bill hash so the search
  # results table and the Save form can share the same object.
  def self.from_api(data)
    latest = data['latestAction'] || {}
    bill = new(
      title: data['title'],
      congress: data['congress'],
      number: data['number'],
      type: data['type'].to_s.downcase,
      original_chamber: data['originChamber']
    )
    bill.last_action = format_last_action(latest['text'], latest['actionDate'])
    bill
  end

  # e.g. "Became Public Law No: 117-108 on Apr 6, 2024"
  def self.format_last_action(text, date_str)
    return text.to_s if date_str.blank?

    date = begin
      Date.parse(date_str)
    rescue ArgumentError, TypeError
      nil
    end
    return text.to_s unless date

    "#{text} on #{date.strftime('%b %-d, %Y')}".strip
  end

  # e.g. "HR 123" — the short type label followed by the bill number.
  def display_number
    "#{self.class.label_for(type)} #{number}".strip
  end

  def self.label_for(type_code)
    TYPE_LABELS.fetch(type_code.to_s.downcase, type_code.to_s.upcase)
  end
end
