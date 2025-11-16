# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard', type: :request do
  let(:user) { create(:user) }
  let(:energy_type) { create(:energy_type, user: user) }
  let(:another_energy_type) { create(:energy_type, user: user) }

  before do
    sign_in user
  end

  describe 'GET /dashboard' do
    it 'returns a successful response' do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it 'displays energy types in the response' do
      create(:energy_type, user: user, name: 'B Energy')
      create(:energy_type, user: user, name: 'A Energy')

      get root_path

      expect(response.body).to include('A Energy')
      expect(response.body).to include('B Energy')
    end

    context 'with no data' do
      it 'returns successful response with empty data' do
        get root_path

        expect(response).to have_http_status(:success)
      end
    end

    context 'isolation between users' do
      let(:other_user) { create(:user) }
      let(:other_energy_type) { create(:energy_type, user: other_user, name: 'Other User Energy') }

      before do
        create(:consumption, user: other_user, energy_type: other_energy_type, value: 500)
      end

      it 'does not show other users energy types' do
        energy_type

        get root_path

        expect(response.body).not_to include('Other User Energy')
        expect(response.body).to include(energy_type.name)
      end
    end

    context 'when not authenticated' do
      before do
        sign_out user
        get root_path
      end

      it_behaves_like 'requires authentication'
    end
  end
end
