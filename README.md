# Migration Lock Timeout

Migration Lock Timeout is a Ruby gem that adds a lock timeout to all Active
Record migrations in your Ruby on Rails project. A lock timeout sets a timeout
on how long PostgreSQL will wait to acquire a lock on tables being altered
before failing and rolling back. This prevents migrations from creating
additional lock contention that can take down your site when it's under heavy
load. Migration Lock Timeout currently only supports [PostgreSQL](https://www.postgresql.org/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'migration-lock-timeout'
```

## Usage

Configure the default lock timeout in a Rails initializer

```ruby
#config/initializers/migration_lock_timeout.rb

MigrationLockTimeout.configure do |config|
  config.default_timeout = 5 #timeout in seconds
end
```

And that's all! Now every `up` migration will execute
```psql
SET LOCAL lock_timeout = '5s';
```
inside the migration transaction before your migration code runs. No lock
timeout will be used for the `down` migration.

## Disabling

You can disable the lock timeout by using:
```ruby
  class AddFoo < ActiveRecord::Migration

    disable_lock_timeout!

    def change
      create_table :foo do |t|
        t.timestamps
      end
    end
  end
```

## Custom lock timeout

You can change the duration of the lock timeout by using:
```ruby
  class AddBar < ActiveRecord::Migration

    set_lock_timeout 10

    def change
      create_table :bar do |t|
        t.timestamps
      end
    end
  end
```
Additionally, if you have not set a default lock timeout, you can use this to
set a timeout for a particular migration.

## disable_ddl_transaction!

If you use `disable_ddl_transaction!`, no lock timeout will occur
```ruby
  class AddMonkey < ActiveRecord::Migration

    disable_ddl_transaction!

    def change
      create_table :monkey do |t|
        t.timestamps
      end
    end
  end
```

## Running the specs

To run the specs you must have [PostgreSQL](https://www.postgresql.org/)
installed. Create a database called `migration_lock_timeout_test` and set the
environment variables `POSTGRES_DB_USERNAME` and `POSTGRES_DB_PASSWORD` then run
`rspec`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/procore-oss/migration-lock-timeout. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## About Procore

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/procore-oss/.github/blob/main/procoredarklogo.png?raw=true">
  <img alt="Procore Open Source" src="https://raw.githubusercontent.com/procore-oss/.github/main/procorelightlogo.png">
</picture>

Migration Lock Timeout is maintained by Procore Technologies.

Procore - building the software that builds the world.

Learn more about the #1 most widely used construction management software at [procore.com](https://www.procore.com/)
