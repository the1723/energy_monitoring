# frozen_string_literal: true

class EnergyTypesController < ApplicationController
  before_action :set_energy_type, only: %i[edit update destroy]

  def index
    @pagy, @energy_types = pagy(:offset, current_user.energy_types.order(:name))
  end

  def new
    @energy_type = EnergyType.new
  end

  def edit; end

  def create
    @energy_type = current_user.energy_type.build(energy_type_params)

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

  def set_energy_type
    @energy_type = current_user.energy_types.find(params.expect(:id))
  end

  def energy_type_params
    params.expect(energy_type: %i[name unit])
  end
end
