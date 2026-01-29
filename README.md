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

When you use `disable_ddl_transaction!`, the gem automatically switches to using a session-level lock timeout instead of a transaction-level timeout. This is necessary because non-transactional migrations don't run inside a database transaction, so the `SET LOCAL` command (which only applies within a transaction) wouldn't work.

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

For this migration, the gem will execute:
```psql
SET lock_timeout = '5s';  -- Session-level timeout
-- Your migration code runs here
RESET lock_timeout;       -- Reset to default after migration
```

This is particularly useful for operations that require `disable_ddl_transaction!`, such as:
- Creating indexes concurrently (`add_index :table, :column, algorithm: :concurrently`)
- Adding columns with a default value in older PostgreSQL versions
- Other operations that cannot run inside a transaction

**Note:** The lock timeout is automatically reset after the migration completes to avoid affecting subsequent database operations.

**Important:** If you need to disable the lock timeout for a specific non-transactional migration (for example, if the operation legitimately needs to wait longer for locks), you can combine `disable_ddl_transaction!` with `disable_lock_timeout!`:

```ruby
  class AddIndexConcurrently < ActiveRecord::Migration
    disable_ddl_transaction!
    disable_lock_timeout!  # Explicitly disable timeout for this migration

    def change
      add_index :large_table, :column, algorithm: :concurrently
    end
  end
```

Alternatively, you can set a custom timeout for the migration:

```ruby
  class AddIndexConcurrently < ActiveRecord::Migration
    disable_ddl_transaction!
    set_lock_timeout 30  # Wait up to 30 seconds for locks

    def change
      add_index :large_table, :column, algorithm: :concurrently
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
