# frozen_string_literal: true

class DashboardController < ApplicationController
  def index # rubocop:disable Metrics/AbcSize
    @energy_types = current_user.energy_types.order(:name).load

    # Filter parameters - default to first energy type if none selected
    @selected_energy_type_id = params[:energy_type_id].presence || @energy_types.first&.id
    @selected_energy_type = @energy_types.find { |et| et.id.to_s == @selected_energy_type_id.to_s }
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 1.month.ago.to_date
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Time.zone.today
    @period = params[:period] || 'day'

    # Use service to get chart data and statistics
    @chart_data = DashboardCharts.new(
      user: current_user,
      energy_type_id: @selected_energy_type_id,
      start_date: @start_date,
      end_date: @end_date,
      period: @period
    ).call
  end
end
