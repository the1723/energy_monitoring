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
require 'rails_helper'

RSpec.describe EnergyType, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:consumptions).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:energy_type) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:unit) }

    context 'uniqueness validation' do
      let(:user) { create(:user) }

      it 'allows energy types with the same name for different users' do
        create(:energy_type, name: 'Electricity', user: user)
        user2 = create(:user)
        energy_type2 = build(:energy_type, name: 'Electricity', user: user2)

        expect(energy_type2).to be_valid
      end

      it 'does not allow duplicate energy type names for the same user' do
        create(:energy_type, name: 'Electricity', user: user)
        energy_type2 = build(:energy_type, name: 'Electricity', user: user)

        expect(energy_type2).not_to be_valid
        expect(energy_type2.errors[:name]).to include('has already been taken')
      end

      it 'allows different names for the same user' do
        create(:energy_type, name: 'Electricity', user: user)
        energy_type2 = build(:energy_type, name: 'Gas', user: user)

        expect(energy_type2).to be_valid
      end
    end
  end

  describe '#name_with_unit' do
    it 'returns the name with unit in parentheses' do
      energy_type = build(:energy_type, name: 'Electricity', unit: 'kWh')
      expect(energy_type.name_with_unit).to eq('Electricity (kWh)')
    end
  end
end
