# frozen_string_literal: true

# rubocop:disable Rails/Output
# Clear existing data in development
if Rails.env.development?
  puts 'Cleaning existing data...'
  Consumption.destroy_all
  EnergyType.destroy_all
  User.destroy_all
end

# Create a demo user
puts 'Creating demo user...'
user = User.find_or_create_by!(email: 'demo@example.com') do |u|
  u.name = 'Demo User'
  u.password = 'password123'
  u.password_confirmation = 'password123'
end

# Create energy types
puts 'Creating energy types...'
electricity = EnergyType.find_or_create_by!(user: user, name: 'Electricity') do |et|
  et.unit = 'kWh'
end

gas = EnergyType.find_or_create_by!(user: user, name: 'Natural Gas') do |et|
  et.unit = 'm³'
end

water = EnergyType.find_or_create_by!(user: user, name: 'Water') do |et|
  et.unit = 'L'
end

heating = EnergyType.find_or_create_by!(user: user, name: 'Heating') do |et|
  et.unit = 'kWh'
end

# Generate consumption data for the past year
puts 'Generating consumption data...'

# Helper method to generate realistic consumption patterns
def generate_consumption_value(_energy_type_name, month, base_value)
  # Add seasonal variation
  seasonal_factor = case month
                    when 12, 1, 2 # Winter
                      1.3
                    when 6, 7, 8 # Summer
                      1.1
                    else # Spring/Fall
                      1.0
                    end

  # Add some randomness
  random_factor = 0.8 + (rand * 0.4) # Between 0.8 and 1.2

  (base_value * seasonal_factor * random_factor).round
end

# Generate data for the past 12 months
(0..365).each do |days_ago|
  date = days_ago.days.ago

  # Electricity: ~300-500 kWh per month, daily readings
  if (days_ago % 1).zero? # Daily
    Consumption.find_or_create_by!(
      user: user,
      energy_type: electricity,
      date_of_reading: date.beginning_of_day
    ) do |c|
      c.value = generate_consumption_value('Electricity', date.month, rand(10..20))
    end
  end

  # Natural Gas: readings every 3 days
  if (days_ago % 3).zero?
    Consumption.find_or_create_by!(
      user: user,
      energy_type: gas,
      date_of_reading: date.beginning_of_day
    ) do |c|
      c.value = generate_consumption_value('Natural Gas', date.month, rand(5..15))
    end
  end

  # Water: weekly readings
  if (days_ago % 7).zero?
    Consumption.find_or_create_by!(
      user: user,
      energy_type: water,
      date_of_reading: date.beginning_of_day
    ) do |c|
      c.value = generate_consumption_value('Water', date.month, rand(1000..2000))
    end
  end

  # Heating: daily in winter, less frequent in summer
  frequency = [12, 1, 2, 3, 11].include?(date.month) ? 1 : 7 # rubocop:disable Performance/CollectionLiteralInLoop
  next unless (days_ago % frequency).zero?

  Consumption.find_or_create_by!(
    user: user,
    energy_type: heating,
    date_of_reading: date.beginning_of_day
  ) do |c|
    c.value = generate_consumption_value('Heating', date.month, rand(20..40))
  end
end

puts 'Seed data created successfully!'
puts 'Demo user credentials:'
puts '  Email: demo@example.com'
puts '  Password: password123'
puts ''
puts "Energy types created: #{EnergyType.count}"
puts "Consumption records created: #{Consumption.count}"
# rubocop:enable Rails/Output
