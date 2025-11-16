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
require 'rails_helper'

RSpec.describe Consumption, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
