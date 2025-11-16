# frozen_string_literal: true

# == Schema Information
#
# Table name: consumptions
#
#  id              :integer          not null, primary key
#  date_of_reading :datetime         not null
#  value           :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  energy_type_id  :integer          not null
#  user_id         :integer          not null
#
# Indexes
#
#  index_consumptions_on_user_energy_type_date  (user_id,energy_type_id,date_of_reading) UNIQUE
#
# Foreign Keys
#
#  energy_type_id  (energy_type_id => energy_types.id)
#  user_id         (user_id => users.id)
#
class Consumption < ApplicationRecord
  belongs_to :energy_type
  belongs_to :user

  validates :value, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :date_of_reading, presence: true
  # Ensure uniqueness of consumption per user, energy type, and date_of_reading
  validates :date_of_reading, uniqueness: {
    scope: %i[user_id energy_type_id],
    message: 'Consumption for this energy type and date already exists'
  }
end
