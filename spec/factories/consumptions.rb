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
FactoryBot.define do
  factory :consumption do
    energy_type { nil }
    value { 1 }
    date_of_reading { '2025-11-16 16:33:39' }
    user { nil }
  end
end
