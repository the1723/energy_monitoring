# frozen_string_literal: true

class EnergyTypesController < ApplicationController
  before_action :set_energy_type, only: %i[show edit update destroy]

  # GET /energy_types or /energy_types.json
  def index
    @energy_types = current_user.energy_types.all
  end

  # GET /energy_types/1 or /energy_types/1.json
  def show; end

  # GET /energy_types/new
  def new
    @energy_type = EnergyType.new
  end

  # GET /energy_types/1/edit
  def edit; end

  # POST /energy_types or /energy_types.json
  def create
    @energy_type = EnergyType.new(energy_type_params)

    respond_to do |format|
      if @energy_type.save
        format.html { redirect_to @energy_type, notice: 'Energy type was successfully created.' }
        format.json { render :show, status: :created, location: @energy_type }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @energy_type.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /energy_types/1 or /energy_types/1.json
  def update
    respond_to do |format|
      if @energy_type.update(energy_type_params)
        format.html { redirect_to @energy_type, notice: 'Energy type was successfully updated.', status: :see_other }
        format.json { render :show, status: :ok, location: @energy_type }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @energy_type.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /energy_types/1 or /energy_types/1.json
  def destroy
    @energy_type.destroy!

    respond_to do |format|
      format.html do
        redirect_to energy_types_path, notice: 'Energy type was successfully destroyed.', status: :see_other
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_energy_type
    @energy_type = EnergyType.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def energy_type_params
    params.expect(energy_type: %i[name unit user_id])
  end
end
