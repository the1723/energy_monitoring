# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @energy_types = current_user.energy_types.order(:name).load

    # Filter parameters - default to first energy type if none selected
    @selected_energy_type_id = params[:energy_type_id].presence || @energy_types.first&.id
    @selected_energy_type = @energy_types.find { |et| et.id.to_s == @selected_energy_type_id.to_s }
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 1.year.ago.to_date
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

    # Preload recent consumptions for table display
    @recent_consumptions = current_user.consumptions
                                       .where(energy_type_id: @selected_energy_type_id)
                                       .where(date_of_reading: @start_date.beginning_of_day..@end_date.end_of_day)
                                       .order(date_of_reading: :desc)
                                       .limit(10)
                                       .to_a
  end
end
