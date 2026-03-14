# Ruby Commands

## Bundler
- `bundle install` — install dependencies from Gemfile.lock
- `bundle update` — update all gems to latest matching versions
- `bundle add gem_name` — add a gem to the Gemfile and install
- `bundle exec <command>` — run command in context of bundle

## Testing
- `bundle exec rspec` — run all RSpec tests
- `bundle exec rspec spec/models/user_spec.rb` — run a specific file
- `bundle exec rspec spec/models/user_spec.rb:42` — run a specific line
- `bundle exec rspec --tag focus` — run only focused tests
- `bundle exec rspec --format documentation` — verbose output
- `bundle exec rails test` — run Minitest tests
- `bundle exec rails test test/models/user_test.rb` — specific Minitest file

## Rails
- `bin/rails server` — start development server
- `bin/rails console` — interactive REPL with app loaded
- `bin/rails db:migrate` — run pending migrations
- `bin/rails db:reset` — drop, create, migrate, seed
- `bin/rails generate model User name:string email:string` — generate model
- `bin/rails routes` — show all routes
- `bin/rails db:seed` — run seed data

## Linting
- `bundle exec rubocop` — run RuboCop linter
- `bundle exec rubocop -a` — auto-fix safe violations
- `bundle exec rubocop -A` — auto-fix all violations (including unsafe)
- `bundle exec rubocop --only Style/FrozenStringLiteral` — check specific cop

## Rake
- `bundle exec rake -T` — list all available tasks
- `bundle exec rake db:migrate` — run migrations (non-Rails or older Rails)
- `bundle exec rake assets:precompile` — compile assets for production

## Background Jobs
- `bundle exec sidekiq` — start Sidekiq worker
- `bundle exec sidekiq -q critical -q default` — start with queue priority

## Production
- `RAILS_ENV=production bundle exec rails assets:precompile` — precompile assets
- `RAILS_ENV=production bundle exec rails db:migrate` — run production migrations
