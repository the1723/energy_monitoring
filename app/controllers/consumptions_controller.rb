# frozen_string_literal: true

class ConsumptionsController < ApplicationController
  before_action :set_consumption, only: %i[show edit update destroy]

  # GET /consumptions or /consumptions.json
  def index
    @consumptions = Consumption.all
  end

  # GET /consumptions/1 or /consumptions/1.json
  def show; end

  # GET /consumptions/new
  def new
    @consumption = Consumption.new
  end

  # GET /consumptions/1/edit
  def edit; end

  # POST /consumptions or /consumptions.json
  def create
    @consumption = Consumption.new(consumption_params)

    respond_to do |format|
      if @consumption.save
        format.html { redirect_to @consumption, notice: 'Consumption was successfully created.' }
        format.json { render :show, status: :created, location: @consumption }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @consumption.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /consumptions/1 or /consumptions/1.json
  def update
    respond_to do |format|
      if @consumption.update(consumption_params)
        format.html { redirect_to @consumption, notice: 'Consumption was successfully updated.', status: :see_other }
        format.json { render :show, status: :ok, location: @consumption }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @consumption.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /consumptions/1 or /consumptions/1.json
  def destroy
    @consumption.destroy!

    respond_to do |format|
      format.html do
        redirect_to consumptions_path, notice: 'Consumption was successfully destroyed.', status: :see_other
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_consumption
    @consumption = Consumption.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def consumption_params
    params.expect(consumption: %i[energy_type_id value date_of_reading user_id])
  end
end
