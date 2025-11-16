# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardCharts, type: :service do
  let(:user) { create(:user, email: 'test@example.com', password: 'password', name: 'Test User') }
  let(:energy_type) { create(:energy_type, user: user, name: 'Electricity', unit: 'kWh') }
  let(:start_date) { Date.new(2025, 1, 1) }
  let(:end_date) { Date.new(2025, 1, 31) }
  let(:period) { 'day' }

  let(:service) do
    described_class.new(
      user: user,
      energy_type_id: energy_type.id,
      start_date: start_date,
      end_date: end_date,
      period: period
    )
  end

  before do
    # Create test data for January 2025
    create(:consumption, user: user, energy_type: energy_type, date_of_reading: Date.new(2025, 1, 1), value: 100)
    create(:consumption, user: user, energy_type: energy_type, date_of_reading: Date.new(2025, 1, 2), value: 150)
    create(:consumption, user: user, energy_type: energy_type, date_of_reading: Date.new(2025, 1, 3), value: 120)
    create(:consumption, user: user, energy_type: energy_type, date_of_reading: Date.new(2025, 1, 15), value: 200)
    create(:consumption, user: user, energy_type: energy_type, date_of_reading: Date.new(2025, 1, 31), value: 180)

    # Create data for previous period (December 2024)
    create(:consumption, user: user, energy_type: energy_type, date_of_reading: Date.new(2024, 12, 1), value: 90)
    create(:consumption, user: user, energy_type: energy_type, date_of_reading: Date.new(2024, 12, 15), value: 110)
    create(:consumption, user: user, energy_type: energy_type, date_of_reading: Date.new(2024, 12, 31), value: 95)

    # Create data for current month (November 2025)
    create(:consumption, user: user, energy_type: energy_type, date_of_reading: Date.new(2025, 11, 1), value: 130)
    create(:consumption, user: user, energy_type: energy_type, date_of_reading: Date.new(2025, 11, 10), value: 140)
  end

  describe '#call' do
    it 'returns a hash with chart_data, comparison_data, and statistics' do
      result = service.call

      expect(result).to be_a(Hash)
      expect(result).to have_key(:chart_data)
      expect(result).to have_key(:comparison_data)
      expect(result).to have_key(:statistics)
    end

    it 'returns correct structure for statistics' do
      result = service.call
      stats = result[:statistics]

      expect(stats).to include(
        :total_consumption,
        :average_daily_consumption,
        :monthly_peak_month,
        :monthly_peak_value,
        :current_month_total
      )
    end
  end

  describe '#statistics' do
    it 'calculates correct total consumption' do
      stats = service.send(:statistics)
      # 100 + 150 + 120 + 200 + 180 = 750
      expect(stats[:total_consumption]).to eq(750)
    end

    it 'calculates correct average daily consumption' do
      stats = service.send(:statistics)
      # 750 / 31 days = 24.19
      expect(stats[:average_daily_consumption]).to eq(24.19)
    end

    it 'returns N/A for monthly peak when no data' do
      empty_service = described_class.new(
        user: user,
        energy_type_id: energy_type.id,
        start_date: Date.new(2026, 1, 1),
        end_date: Date.new(2026, 1, 31),
        period: 'month'
      )

      stats = empty_service.send(:statistics)
      expect(stats[:monthly_peak_month]).to eq('N/A')
      expect(stats[:monthly_peak_value]).to eq(0)
    end
  end

  describe '#chart_data' do
    context 'when period is day' do
      let(:period) { 'day' }

      it 'groups data by day' do
        chart_data = service.send(:chart_data)

        expect(chart_data).to be_a(Hash)
        expect(chart_data[Date.new(2025, 1, 1)]).to eq(100)
        expect(chart_data[Date.new(2025, 1, 2)]).to eq(150)
        expect(chart_data[Date.new(2025, 1, 3)]).to eq(120)
      end
    end

    context 'when period is week' do
      let(:period) { 'week' }

      it 'groups data by week' do
        chart_data = service.send(:chart_data)

        expect(chart_data).to be_a(Hash)
        expect(chart_data.values.sum).to eq(750) # Total consumption
      end
    end

    context 'when period is month' do
      let(:period) { 'month' }
      let(:start_date) { Date.new(2024, 12, 1) }
      let(:end_date) { Date.new(2025, 1, 31) }

      it 'groups data by month with correct format' do
        chart_data = service.send(:chart_data)

        expect(chart_data).to be_a(Hash)
        expect(chart_data.keys).to all(be_a(String))
        expect(chart_data.keys.first).to match(/\w{3} \d{4}/) # Format: "Jan 2025"
      end
    end

    context 'when period is year' do
      let(:period) { 'year' }
      let(:start_date) { Date.new(2024, 1, 1) }
      let(:end_date) { Date.new(2025, 12, 31) }

      it 'groups data by year' do
        chart_data = service.send(:chart_data)

        expect(chart_data).to be_a(Hash)
        # Grouper returns Date objects (first day of year) as keys
        expect(chart_data.values.sum).to be > 0
        expect(chart_data.keys).to all(be_a(Date).or(be_a(Time)))
      end
    end

    context 'when period is invalid' do
      let(:period) { 'invalid' }

      it 'defaults to day grouping' do
        chart_data = service.send(:chart_data)

        expect(chart_data).to be_a(Hash)
        expect(chart_data[Date.new(2025, 1, 1)]).to eq(100)
      end
    end
  end

  describe '#total_consumption' do
    it 'returns the sum of all consumption values in the period' do
      total = service.send(:total_consumption)
      expect(total).to eq(750)
    end

    it 'returns 0 when no consumptions exist' do
      empty_service = described_class.new(
        user: user,
        energy_type_id: energy_type.id,
        start_date: Date.new(2026, 1, 1),
        end_date: Date.new(2026, 1, 31),
        period: 'day'
      )

      total = empty_service.send(:total_consumption)
      expect(total).to eq(0)
    end
  end

  describe '#average_daily_consumption' do
    it 'calculates correct average for the period' do
      avg = service.send(:average_daily_consumption)
      expect(avg).to eq(24.19) # 750 / 31 days
    end

    it 'returns 0 when period has zero days' do
      # This shouldn't happen in practice, but test edge case
      service_instance = described_class.new(
        user: user,
        energy_type_id: energy_type.id,
        start_date: Date.new(2025, 1, 2),
        end_date: Date.new(2025, 1, 1), # End before start
        period: 'day'
      )

      avg = service_instance.send(:average_daily_consumption)
      expect(avg).to eq(0)
    end
  end

  describe '#current_month_total' do
    it 'calculates total for current month' do
      # Mock today to be November 16, 2025
      allow(Time.zone).to receive(:today).and_return(Date.new(2025, 11, 16))

      current_total = service.send(:current_month_total)
      expect(current_total).to eq(270) # 130 + 140
    end
  end

  describe '#monthly_peak' do
    let(:period) { 'month' }
    let(:start_date) { Date.new(2024, 12, 1) }
    let(:end_date) { Date.new(2025, 1, 31) }

    it 'finds the month with highest consumption' do
      peak = service.send(:monthly_peak)

      expect(peak).to be_an(Array)
      expect(peak.last).to eq(750) # January has highest consumption
    end

    it 'returns nil when no data exists' do
      empty_service = described_class.new(
        user: user,
        energy_type_id: energy_type.id,
        start_date: Date.new(2026, 1, 1),
        end_date: Date.new(2026, 1, 31),
        period: 'month'
      )

      peak = empty_service.send(:monthly_peak)
      expect(peak).to be_nil
    end
  end

  describe '#monthly_peak_month' do
    let(:period) { 'month' }
    let(:start_date) { Date.new(2024, 12, 1) }
    let(:end_date) { Date.new(2025, 1, 31) }

    it 'returns the name of the peak month' do
      peak_month = service.send(:monthly_peak_month)
      expect(peak_month).to be_a(String)
    end

    it 'returns N/A when no data exists' do
      empty_service = described_class.new(
        user: user,
        energy_type_id: energy_type.id,
        start_date: Date.new(2026, 1, 1),
        end_date: Date.new(2026, 1, 31),
        period: 'month'
      )

      peak_month = empty_service.send(:monthly_peak_month)
      expect(peak_month).to eq('N/A')
    end
  end

  describe '#monthly_peak_value' do
    let(:period) { 'month' }
    let(:start_date) { Date.new(2024, 12, 1) }
    let(:end_date) { Date.new(2025, 1, 31) }

    it 'returns the consumption value of the peak month' do
      peak_value = service.send(:monthly_peak_value)
      expect(peak_value).to eq(750) # January total
    end

    it 'returns 0 when no data exists' do
      empty_service = described_class.new(
        user: user,
        energy_type_id: energy_type.id,
        start_date: Date.new(2026, 1, 1),
        end_date: Date.new(2026, 1, 31),
        period: 'month'
      )

      peak_value = empty_service.send(:monthly_peak_value)
      expect(peak_value).to eq(0)
    end
  end

  describe '#all_time_daily_avg' do
    it 'calculates average across all consumption records for the energy type' do
      avg = service.send(:all_time_daily_avg)

      # All data spans from 2024-12-01 to 2025-11-10 = 345 days
      # Total: 90+110+95+100+150+120+200+180+130+140 = 1315
      # Average: 1315 / 345 = 3.81
      expect(avg).to be_a(Float)
      expect(avg).to be > 0
    end

    it 'returns 0 when no consumption records exist' do
      another_energy_type = create(:energy_type, user: user, name: 'Gas', unit: 'm³')
      empty_service = described_class.new(
        user: user,
        energy_type_id: another_energy_type.id,
        start_date: start_date,
        end_date: end_date,
        period: 'day'
      )

      avg = empty_service.send(:all_time_daily_avg)
      expect(avg).to eq(0)
    end
  end

  describe '#previous_daily_avg' do
    it 'calculates average for the previous period' do
      # Period: Jan 1-31 (30 days duration: 31-1=30)
      # Previous period: Dec 2-31 (30 days before Jan 1)
      # Previous total: 110 + 95 = 205 (Dec 1 is excluded)
      # Average: 205 / 30 = 6.83

      avg = service.send(:previous_daily_avg)
      expect(avg).to eq(6.83)
    end

    it 'returns 0 when no data exists for previous period' do
      future_service = described_class.new(
        user: user,
        energy_type_id: energy_type.id,
        start_date: Date.new(2026, 1, 1),
        end_date: Date.new(2026, 1, 31),
        period: 'day'
      )

      avg = future_service.send(:previous_daily_avg)
      expect(avg).to eq(0)
    end
  end

  describe '#comparison_data' do
    it 'returns an array with three comparison entries' do
      comparison = service.send(:comparison_data)

      expect(comparison).to be_an(Array)
      expect(comparison.length).to eq(3)
    end

    it 'includes current period data' do
      comparison = service.send(:comparison_data)
      current = comparison.find { |c| c[:name] == 'Current Period' }

      expect(current).to be_present
      expect(current[:data]['Daily Avg']).to eq(24.19)
    end

    it 'includes previous period data' do
      comparison = service.send(:comparison_data)
      previous = comparison.find { |c| c[:name] == 'Previous Period' }

      expect(previous).to be_present
      expect(previous[:data]['Daily Avg']).to eq(6.83)
    end

    it 'includes all-time average data' do
      comparison = service.send(:comparison_data)
      all_time = comparison.find { |c| c[:name] == 'All-Time Avg' }

      expect(all_time).to be_present
      expect(all_time[:data]['Daily Avg']).to be_a(Float)
    end
  end

  describe 'isolation between users' do
    let(:other_user) { create(:user, email: 'other@example.com', password: 'password', name: 'Other User') }
    let(:other_energy_type) { create(:energy_type, user: other_user, name: 'Gas', unit: 'm³') }

    before do
      create(:consumption, user: other_user, energy_type: other_energy_type, date_of_reading: Date.new(2025, 1, 1), value: 999)
    end

    it 'does not include other users data in calculations' do
      total = service.send(:total_consumption)
      expect(total).to eq(750) # Should not include the 999 from other user
    end
  end

  describe 'isolation between energy types' do
    let(:another_energy_type) { create(:energy_type, user: user, name: 'Gas', unit: 'm³') }

    before do
      create(:consumption, user: user, energy_type: another_energy_type, date_of_reading: Date.new(2025, 1, 1), value: 888)
    end

    it 'does not include other energy types in calculations' do
      total = service.send(:total_consumption)
      expect(total).to eq(750) # Should not include the 888 from gas
    end
  end
end
