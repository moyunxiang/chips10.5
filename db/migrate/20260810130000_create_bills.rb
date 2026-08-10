# frozen_string_literal: true

class CreateBills < ActiveRecord::Migration[7.2]
  def change
    create_table :bills do |t|
      t.string :title
      t.integer :congress
      t.integer :number
      t.string :original_chamber
      t.text :type
      t.text :summary

      t.timestamps
    end
  end
end
