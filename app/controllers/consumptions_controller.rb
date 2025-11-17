# frozen_string_literal: true

class ConsumptionsController < ApplicationController
  before_action :set_consumption, only: %i[edit update destroy]

  def index
    @pagy, @consumptions = pagy(:offset, current_user.consumptions.includes(:energy_type).order(date_of_reading: :desc))
  end

  def new
    @consumption = Consumption.new
  end

  def edit; end

  # POST /consumptions or /consumptions.json
  def create
    @consumption = current_user.consumptions.build(consumption_params)

    if @consumption.save
      redirect_to consumptions_path, notice: 'Consumption was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /consumptions/1 or /consumptions/1.json
  def update
    if @consumption.update(consumption_params)
      redirect_to consumptions_path, notice: 'Consumption was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /consumptions/1 or /consumptions/1.json
  def destroy
    @consumption.destroy!

    redirect_to consumptions_path, notice: 'Consumption was successfully destroyed.', status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_consumption
    @consumption = current_user.consumptions.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def consumption_params
    params.expect(consumption: %i[energy_type_id value date_of_reading])
  end
end
