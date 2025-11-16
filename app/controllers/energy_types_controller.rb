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
    @energy_type = current_user.energy_types.build(energy_type_params)

    if @energy_type.save
      redirect_to @energy_type, notice: 'Energy type was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @energy_type.update(energy_type_params)
      redirect_to @energy_type, notice: 'Energy type was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @energy_type.destroy!

    redirect_to energy_types_path, notice: 'Energy type was successfully destroyed.', status: :see_other
  end

  private

  def set_energy_type
    @energy_type = current_user.energy_types.find(params.expect(:id))
  end

  def energy_type_params
    params.expect(energy_type: %i[name unit])
  end
end
