# frozen_string_literal: true

# == Schema Information
#
# Table name: energy_types
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  unit       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_energy_types_on_user_id           (user_id)
#  index_energy_types_on_user_id_and_name  (user_id,name) UNIQUE
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
FactoryBot.define do
  factory :energy_type do
    name { 'MyString' }
    unit { 'MyString' }
    user { nil }
  end
end
