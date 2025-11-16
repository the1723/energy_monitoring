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
  describe 'associations' do
    it { is_expected.to belong_to(:energy_type) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:consumption) }

    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:date_of_reading) }
    it { is_expected.to validate_numericality_of(:value).only_integer.is_greater_than_or_equal_to(0) }

    context 'uniqueness validation' do
      let(:user) { create(:user) }
      let(:energy_type) { create(:energy_type, user: user) }
      let(:date) { Time.zone.now }

      it 'allows consumptions with different dates for same user and energy type' do
        create(:consumption, user: user, energy_type: energy_type, date_of_reading: date)
        consumption2 = build(:consumption, user: user, energy_type: energy_type, date_of_reading: date + 1.day)

        expect(consumption2).to be_valid
      end

      it 'allows consumptions with different energy types for same user and date' do
        energy_type2 = create(:energy_type, user: user, name: 'Gas')
        create(:consumption, user: user, energy_type: energy_type, date_of_reading: date)
        consumption2 = build(:consumption, user: user, energy_type: energy_type2, date_of_reading: date)

        expect(consumption2).to be_valid
      end

      it 'allows consumptions with different users for same energy type and date' do
        user2 = create(:user)
        energy_type2 = create(:energy_type, user: user2)
        create(:consumption, user: user, energy_type: energy_type, date_of_reading: date)
        consumption2 = build(:consumption, user: user2, energy_type: energy_type2, date_of_reading: date)

        expect(consumption2).to be_valid
      end

      it 'does not allow duplicate consumption for same user, energy type, and date' do
        create(:consumption, user: user, energy_type: energy_type, date_of_reading: date)
        consumption2 = build(:consumption, user: user, energy_type: energy_type, date_of_reading: date)

        expect(consumption2).not_to be_valid
        expect(consumption2.errors[:date_of_reading]).to include('Consumption for this energy type and date already exists')
      end
    end
  end

  describe 'value validation' do
    let(:consumption) { build(:consumption) }

    it 'is valid with a value of 0' do
      consumption.value = 0
      expect(consumption).to be_valid
    end

    it 'is valid with a positive integer' do
      consumption.value = 100
      expect(consumption).to be_valid
    end

    it 'is invalid with a negative value' do
      consumption.value = -1
      expect(consumption).not_to be_valid
      expect(consumption.errors[:value]).to include('must be greater than or equal to 0')
    end

    it 'is invalid with a nil value' do
      consumption.value = nil
      expect(consumption).not_to be_valid
      expect(consumption.errors[:value]).to include("can't be blank")
    end

    it 'is invalid with a non-integer value' do
      consumption.value = 10.5
      expect(consumption).not_to be_valid
      expect(consumption.errors[:value]).to include('must be an integer')
    end
  end
end
