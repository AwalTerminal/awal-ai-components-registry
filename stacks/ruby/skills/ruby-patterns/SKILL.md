# Ruby Patterns

## Blocks, Procs, and Lambdas

```ruby
# Block — implicit, yielded to
def with_retry(attempts: 3)
  attempts.times do |i|
    return yield
  rescue StandardError => e
    raise if i == attempts - 1
    sleep(2**i)
  end
end

with_retry { api_client.fetch_data }

# Proc — captures block as object, lenient arity
handler = Proc.new { |x, y| x.to_i + y.to_i }
handler.call(1)      # => 1 (y is nil, nil.to_i => 0)

# Lambda — strict arity, returns to caller
validator = ->(val) { val.is_a?(String) && val.length > 0 }
validator.call("")   # => false
validator.call(42)   # ArgumentError if wrong arity

# Method reference
names = ["alice", "bob"]
names.map(&method(:puts))        # passes each to puts
names.map(&:upcase)              # Symbol#to_proc shorthand
```

## Metaprogramming

```ruby
# define_method for dynamic method creation
class ApiClient
  %w[get post put delete].each do |verb|
    define_method(verb) do |path, **opts|
      request(verb.upcase, path, **opts)
    end
  end

  private

  def request(method, path, **opts)
    # HTTP request logic
  end
end

# method_missing — always pair with respond_to_missing?
class DynamicConfig
  def initialize(data) = @data = data

  def method_missing(name, *)
    @data.key?(name.to_s) ? @data[name.to_s] : super
  end

  def respond_to_missing?(name, include_private = false)
    @data.key?(name.to_s) || super
  end
end
```

## Enumerable Mastery

```ruby
orders = Order.all

# Chaining for complex transformations
revenue_by_month = orders
  .select(&:completed?)
  .group_by { |o| o.created_at.beginning_of_month }
  .transform_values { |group| group.sum(&:total) }

# each_with_object avoids reduce's accumulator return trap
word_counts = words.each_with_object(Hash.new(0)) do |word, counts|
  counts[word.downcase] += 1
end

# flat_map, zip, tally
tags = posts.flat_map(&:tags).tally  # { "ruby" => 5, "rails" => 3 }

# lazy for infinite/large sequences
primes = (2..Float::INFINITY).lazy.select { |n|
  (2..Math.sqrt(n)).none? { |d| (n % d).zero? }
}.first(100)
```

## Pattern Matching (Ruby 3.x)

```ruby
case response
in { status: 200, body: { data: Array => items } }
  process_items(items)
in { status: 404 }
  handle_not_found
in { status: (500..) }
  handle_server_error
end

# Find pattern
case users
in [*, { role: "admin", name: String => admin_name }, *]
  puts "Found admin: #{admin_name}"
end

# Pin operator for matching against variables
expected_id = 42
case record
in { id: ^expected_id }
  puts "matched"
end
```

## Rails Patterns

### Service Objects

```ruby
class CreateOrder
  def initialize(user:, cart:, payment_gateway: Stripe::Gateway.new)
    @user = user
    @cart = cart
    @gateway = payment_gateway
  end

  def call
    ActiveRecord::Base.transaction do
      order = @user.orders.create!(
        items: @cart.items,
        total: @cart.total
      )
      charge = @gateway.charge(amount: order.total, customer: @user.stripe_id)
      order.update!(payment_id: charge.id, status: :paid)
      OrderMailer.confirmation(order).deliver_later
      order
    end
  end
end
```

### Concerns and Scopes

```ruby
module Archivable
  extend ActiveSupport::Concern

  included do
    scope :archived, -> { where.not(archived_at: nil) }
    scope :active, -> { where(archived_at: nil) }
  end

  def archive!
    update!(archived_at: Time.current)
  end

  def archived?
    archived_at.present?
  end
end

class Order < ApplicationRecord
  include Archivable

  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :expensive, ->(threshold) { where("total > ?", threshold) }
end
```

## Concurrency

```ruby
# Ractor — true parallelism (no shared mutable state)
workers = 4.times.map do
  Ractor.new { loop { Ractor.yield(Ractor.receive.call) } }
end

# Sidekiq for background jobs
class ImportJob
  include Sidekiq::Job
  sidekiq_options retry: 3, queue: :default

  def perform(file_path)
    CSV.foreach(file_path, headers: true) { |row| User.create!(row.to_h) }
  end
end
```

## Performance

- Use `includes` / `preload` to eliminate N+1 queries
- Use `find_each(batch_size: 1000)` for processing large datasets
- Use `pluck(:column)` instead of `map(&:column)` to avoid loading full records
- Use `select(:id, :name)` to limit columns fetched
- Use fragment caching and Russian doll caching for views
- Profile memory with `memory_profiler` gem; detect N+1 with `bullet` gem
- Use `frozen_string_literal: true` pragma to reduce string allocations

## Testing

### RSpec

```ruby
RSpec.describe CreateOrder do
  subject(:service) { described_class.new(user:, cart:, payment_gateway: gateway) }

  let(:user) { create(:user, :with_stripe) }
  let(:cart) { create(:cart, :with_items) }
  let(:gateway) { instance_double(Stripe::Gateway) }

  before do
    allow(gateway).to receive(:charge).and_return(
      OpenStruct.new(id: "ch_123")
    )
  end

  it "creates a paid order" do
    order = service.call
    expect(order).to be_persisted
    expect(order.status).to eq("paid")
  end

  context "when payment fails" do
    before { allow(gateway).to receive(:charge).and_raise(Stripe::CardError) }

    it "does not create an order" do
      expect { service.call rescue nil }.not_to change(Order, :count)
    end
  end
end
```

### FactoryBot

```ruby
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }

    trait :admin do
      role { :admin }
    end

    trait :with_stripe do
      stripe_id { "cus_#{SecureRandom.hex(8)}" }
    end
  end
end
```
