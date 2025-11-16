# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Consumptions', type: :request do
  let(:user) { create(:user) }
  let(:energy_type) { create(:energy_type, user: user) }
  let(:consumption) { create(:consumption, user: user, energy_type: energy_type) }

  before do
    sign_in user
  end

  describe 'GET /consumptions' do
    it 'returns a successful response' do
      get consumptions_path
      expect(response).to have_http_status(:success)
    end

    it 'displays consumptions ordered by date' do
      older_consumption = create(:consumption, user: user, energy_type: energy_type, date_of_reading: 2.days.ago)
      newer_consumption = create(:consumption, user: user, energy_type: energy_type, date_of_reading: 1.day.ago)

      get consumptions_path
      expect(response.body).to match(/#{newer_consumption.value}.*#{older_consumption.value}/m)
    end

    it 'does not display other users consumptions' do
      other_user = create(:user)
      other_consumption = create(:consumption, user: other_user)

      get consumptions_path
      expect(response.body).not_to include(other_consumption.value.to_s)
    end

    context 'when not authenticated' do
      before do
        sign_out user
        get consumptions_path
      end

      it_behaves_like 'requires authentication'
    end
  end

  describe 'GET /consumptions/new' do
    it 'returns a successful response' do
      get new_consumption_path
      expect(response).to have_http_status(:success)
    end

    context 'when not authenticated' do
      before do
        sign_out user
        get new_consumption_path
      end

      it_behaves_like 'requires authentication'
    end
  end

  describe 'GET /consumptions/:id/edit' do
    it 'returns a successful response' do
      get edit_consumption_path(consumption)
      expect(response).to have_http_status(:success)
    end

    it 'does not allow editing other users consumptions' do
      other_user = create(:user)
      other_consumption = create(:consumption, user: other_user)

      get edit_consumption_path(other_consumption)

      expect(response).to have_http_status(:not_found)
    end

    context 'when not authenticated' do
      before do
        sign_out user
        get edit_consumption_path(consumption)
      end

      it_behaves_like 'requires authentication'
    end
  end

  describe 'POST /consumptions' do
    context 'with valid parameters' do
      let(:valid_attributes) do
        {
          energy_type_id: energy_type.id,
          value: 150,
          date_of_reading: Time.zone.now
        }
      end

      it 'creates a new consumption' do
        expect do
          post consumptions_path, params: { consumption: valid_attributes }
        end.to change(Consumption, :count).by(1)
      end

      it 'redirects to the created consumption' do
        post consumptions_path, params: { consumption: valid_attributes }
        expect(response).to redirect_to(Consumption.last)
      end

      it 'associates consumption with current user' do
        post consumptions_path, params: { consumption: valid_attributes }
        expect(Consumption.last.user).to eq(user)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          energy_type_id: nil,
          value: nil,
          date_of_reading: nil
        }
      end

      it 'does not create a new consumption' do
        expect do
          post consumptions_path, params: { consumption: invalid_attributes }
        end.not_to change(Consumption, :count)
      end

      it 'returns unprocessable content status' do
        post consumptions_path, params: { consumption: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when not authenticated' do
      before do
        sign_out user
        post consumptions_path, params: { consumption: { value: 100 } }
      end

      it_behaves_like 'requires authentication'
    end
  end

  describe 'PATCH /consumptions/:id' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          value: 200
        }
      end

      it 'updates the consumption' do
        patch consumption_path(consumption), params: { consumption: new_attributes }
        consumption.reload
        expect(consumption.value).to eq(200)
      end

      it 'redirects to the consumption' do
        patch consumption_path(consumption), params: { consumption: new_attributes }
        expect(response).to redirect_to(consumption)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          value: nil
        }
      end

      it 'does not update the consumption' do
        original_value = consumption.value
        patch consumption_path(consumption), params: { consumption: invalid_attributes }
        consumption.reload
        expect(consumption.value).to eq(original_value)
      end

      it 'returns unprocessable content status' do
        patch consumption_path(consumption), params: { consumption: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it 'does not allow updating other users consumptions' do
      other_user = create(:user)
      other_consumption = create(:consumption, user: other_user)

      patch consumption_path(other_consumption), params: { consumption: { value: 300 } }
      expect(response).to have_http_status(:not_found)
    end

    context 'when not authenticated' do
      before do
        sign_out user
        patch consumption_path(consumption), params: { consumption: { value: 250 } }
      end

      it_behaves_like 'requires authentication'
    end
  end

  describe 'DELETE /consumptions/:id' do
    it 'destroys the consumption' do
      consumption
      expect do
        delete consumption_path(consumption)
      end.to change(Consumption, :count).by(-1)
    end

    it 'redirects to consumptions list' do
      delete consumption_path(consumption)
      expect(response).to redirect_to(consumptions_path)
    end

    it 'does not allow deleting other users consumptions' do
      other_user = create(:user)
      other_consumption = create(:consumption, user: other_user)

      delete consumption_path(other_consumption)

      expect(response).to have_http_status(:not_found)
    end

    context 'when not authenticated' do
      before do
        sign_out user
        delete consumption_path(consumption)
      end

      it_behaves_like 'requires authentication'
    end
  end
end
