# frozen_string_literal: true

class CreateConsumptions < ActiveRecord::Migration[8.1]
  def change
    create_table :consumptions do |t|
      t.references :energy_type, null: false, foreign_key: true, index: false
      t.integer :value, null: false
      t.datetime :date_of_reading, null: false
      t.references :user, null: false, foreign_key: true, index: false

      t.timestamps
    end
    add_index :consumptions, %i[user_id energy_type_id date_of_reading], unique: true, name: 'index_consumptions_on_user_energy_type_date'
  end
end
