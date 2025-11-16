# frozen_string_literal: true

class CreateEnergyTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :energy_types do |t|
      t.string :name, null: false
      t.string :unit, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :energy_types, %i[user_id name], unique: true
  end
end
