# frozen_string_literal: true

class DashboardCharts
  attr_reader :user, :energy_type_id, :start_date, :end_date, :period

  def initialize(user:, energy_type_id:, start_date:, end_date:, period: 'day')
    @user = user
    @energy_type_id = energy_type_id
    @start_date = start_date
    @end_date = end_date
    @period = period
  end

  def call
    {
      chart_data: chart_data,
      comparison_data: comparison_data,
      statistics: statistics
    }
  end

  private

  def consumptions
    @consumptions ||= user.consumptions
                          .where(energy_type_id: energy_type_id)
                          .where(date_of_reading: start_date.beginning_of_day..end_date.end_of_day)
  end

  def statistics
    {
      total_consumption: total_consumption,
      average_daily_consumption: average_daily_consumption,
      monthly_peak_month: monthly_peak_month,
      monthly_peak_value: monthly_peak_value,
      current_month_total: current_month_total
    }
  end

  def total_consumption
    @total_consumption ||= consumptions.sum(:value)
  end

  def average_daily_consumption
    days_count = (end_date - start_date).to_i + 1
    days_count.positive? ? (total_consumption.to_f / days_count).round(2) : 0
  end

  def current_month_total
    current_month_start = Time.zone.today.beginning_of_month
    user.consumptions
        .where(energy_type_id: energy_type_id)
        .where(date_of_reading: current_month_start..Time.zone.today.end_of_day)
        .sum(:value)
  end

  def chart_data
    @chart_data ||= case period
                    when 'week'
                      consumptions.group_by_week(:date_of_reading).sum(:value)
                    when 'month'
                      consumptions.group_by_month(:date_of_reading, format: '%b %Y').sum(:value)
                    when 'year'
                      consumptions.group_by_year(:date_of_reading).sum(:value)
                    else
                      consumptions.group_by_day(:date_of_reading).sum(:value)
                    end
  end

  def monthly_peak
    @monthly_peak ||= if period == 'month'
                        chart_data.max_by { |_month, value| value }
                      else
                        monthly_data = consumptions.group_by_month(:date_of_reading, format: '%B %Y').sum(:value)
                        monthly_data.max_by { |_month, value| value }
                      end
  end

  def monthly_peak_month
    monthly_peak&.first || 'N/A'
  end

  def monthly_peak_value
    monthly_peak&.last || 0
  end

  def all_time_daily_avg
    @all_time_daily_avg ||= begin
      all_time_stats = user.consumptions
                           .where(energy_type_id: energy_type_id)
                           .pick('MIN(date_of_reading)', 'MAX(date_of_reading)', 'SUM(value)')

      if all_time_stats[0] && all_time_stats[1]
        all_time_start = all_time_stats[0]
        all_time_end = all_time_stats[1]
        all_time_total = all_time_stats[2] || 0
        all_time_days = (all_time_end.to_date - all_time_start.to_date).to_i + 1
        all_time_days.positive? ? (all_time_total.to_f / all_time_days).round(2) : 0
      else
        0
      end
    end
  end

  def previous_daily_avg
    @previous_daily_avg ||= begin
      period_duration = (end_date - start_date).to_i
      previous_start = start_date - period_duration.days
      previous_end = start_date - 1.day

      previous_total = user.consumptions
                           .where(energy_type_id: energy_type_id)
                           .where(date_of_reading: previous_start.beginning_of_day..previous_end.end_of_day)
                           .sum(:value)

      period_duration.positive? ? (previous_total.to_f / period_duration).round(2) : 0
    end
  end

  def comparison_data
    [
      { name: 'Current Period', data: { 'Daily Avg' => average_daily_consumption } },
      { name: 'Previous Period', data: { 'Daily Avg' => previous_daily_avg } },
      { name: 'All-Time Avg', data: { 'Daily Avg' => all_time_daily_avg } }
    ]
  end
end
