# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'EnergyTypes', type: :request do
  let(:user) { create(:user) }
  let(:energy_type) { create(:energy_type, user: user) }

  before do
    sign_in user
  end

  describe 'GET /energy_types' do
    it 'returns a successful response' do
      get energy_types_path
      expect(response).to have_http_status(:success)
    end

    it 'displays energy types ordered by name' do
      create(:energy_type, user: user, name: 'B Type')
      create(:energy_type, user: user, name: 'A Type')

      get energy_types_path
      expect(response.body).to match(/A Type.*B Type/m)
    end

    it 'does not display other users energy types' do
      other_user = create(:user)
      create(:energy_type, user: other_user, name: 'Other Type')

      get energy_types_path
      expect(response.body).not_to include('Other Type')
    end

    context 'when not authenticated' do
      before do
        sign_out user
        get energy_types_path
      end

      it_behaves_like 'requires authentication'
    end
  end

  describe 'GET /energy_types/new' do
    it 'returns a successful response' do
      get new_energy_type_path
      expect(response).to have_http_status(:success)
    end

    context 'when not authenticated' do
      before do
        sign_out user
        get new_energy_type_path
      end

      it_behaves_like 'requires authentication'
    end
  end

  describe 'GET /energy_types/:id/edit' do
    it 'returns a successful response' do
      get edit_energy_type_path(energy_type)
      expect(response).to have_http_status(:success)
    end

    it 'does not allow editing other users energy types' do
      other_user = create(:user)
      other_energy_type = create(:energy_type, user: other_user)

      get edit_energy_type_path(other_energy_type)

      expect(response).to have_http_status(:not_found)
    end

    context 'when not authenticated' do
      before do
        sign_out user
        get edit_energy_type_path(energy_type)
      end

      it_behaves_like 'requires authentication'
    end
  end

  describe 'POST /energy_types' do
    context 'with valid parameters' do
      let(:valid_attributes) do
        {
          name: 'Electricity',
          unit: 'kWh'
        }
      end

      it 'creates a new energy type' do
        expect do
          post energy_types_path, params: { energy_type: valid_attributes }
        end.to change(EnergyType, :count).by(1)
      end

      it 'redirects to the created energy type' do
        post energy_types_path, params: { energy_type: valid_attributes }
        expect(response).to redirect_to(EnergyType.last)
      end

      it 'associates energy type with current user' do
        post energy_types_path, params: { energy_type: valid_attributes }
        expect(EnergyType.last.user).to eq(user)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          name: nil,
          unit: nil
        }
      end

      it 'does not create a new energy type' do
        expect do
          post energy_types_path, params: { energy_type: invalid_attributes }
        end.not_to change(EnergyType, :count)
      end

      it 'returns unprocessable content status' do
        post energy_types_path, params: { energy_type: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when not authenticated' do
      before do
        sign_out user
        post energy_types_path, params: { energy_type: { name: 'Test' } }
      end

      it_behaves_like 'requires authentication'
    end
  end

  describe 'PATCH /energy_types/:id' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          name: 'Updated Name',
          unit: 'kWh'
        }
      end

      it 'updates the energy type' do
        patch energy_type_path(energy_type), params: { energy_type: new_attributes }
        energy_type.reload
        expect(energy_type.name).to eq('Updated Name')
      end

      it 'redirects to the energy type' do
        patch energy_type_path(energy_type), params: { energy_type: new_attributes }
        expect(response).to redirect_to(energy_type)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          name: nil
        }
      end

      it 'does not update the energy type' do
        original_name = energy_type.name
        patch energy_type_path(energy_type), params: { energy_type: invalid_attributes }
        energy_type.reload
        expect(energy_type.name).to eq(original_name)
      end

      it 'returns unprocessable content status' do
        patch energy_type_path(energy_type), params: { energy_type: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it 'does not allow updating other users energy types' do
      other_user = create(:user)
      other_energy_type = create(:energy_type, user: other_user)

      patch energy_type_path(other_energy_type), params: { energy_type: { name: 'Hacked' } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /energy_types/:id' do
    it 'destroys the energy type' do
      energy_type
      expect do
        delete energy_type_path(energy_type)
      end.to change(EnergyType, :count).by(-1)
    end

    it 'redirects to energy types list' do
      delete energy_type_path(energy_type)
      expect(response).to redirect_to(energy_types_path)
    end

    it 'does not allow deleting other users energy types' do
      other_user = create(:user)
      other_energy_type = create(:energy_type, user: other_user)

      delete energy_type_path(other_energy_type)

      expect(response).to have_http_status(:not_found)
    end

    context 'when not authenticated' do
      before do
        sign_out user
        delete energy_type_path(energy_type)
      end

      it_behaves_like 'requires authentication'
    end
  end
end
