# Energy Monitoring Dashboard

* Rails version 8.1.1
* JS bundler: bun
* CSS: Tailwind + Basecoat

## Features

* User authentication with Devise
* Energy consumption tracking by type
* Dashboard with consumption summaries, charts and filters
* Responsive design for mobile and desktop
* Dark and light mode support
* Eager loading and pagination for performance
* Consumption model uses composite index for fast queries
* Good test coverage with RSpec

## Setup

### Prequisites

* Ruby 3.3.9
* Bun (JS bundler) (Install bun if not installed: `curl -fsSL https://bun.sh/install | bash`)

1. Clone the repository
2. Run `bundle install`
3. Install JS dependencies with `bun install`
4. Set up the database with `rails db:setup`
5. Start with `bin/dev`
6. Access the app at `http://localhost:3000`
7. Demo user credentials:
    * Email: `demo@example.com`
    * Password: `password123`

## Running Tests

Run tests with `bundle exec rspec`
