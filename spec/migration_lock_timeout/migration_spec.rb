# frozen_string_literal: true

require_relative './spec_helper'
require 'active_record'
require 'strong_migrations' if Gem.loaded_specs.has_key? 'strong_migrations'
require_relative '../../lib/migration-lock-timeout'

ACTIVE_RECORD_MIGRATION_CLASS = ActiveRecord::Migration[ActiveRecord::VERSION::STRING.to_f]

def expect_create_table
  if ActiveRecord.gem_version >= '7.1'
    expect(ActiveRecord::Base.connection).to receive(:execute).
      with(/CREATE TABLE/).
      and_call_original
  else
    expect(ActiveRecord::Base.connection).to receive(:execute).
      with('BEGIN', 'TRANSACTION').
      and_call_original
    expect(ActiveRecord::Base.connection).to receive(:execute).
      with(/CREATE TABLE/).
      and_call_original
  end
end

RSpec.describe ActiveRecord::Migration do

  describe '#migrate' do

    before(:each) do
      MigrationLockTimeout.configure do |config|
        config.default_timeout = 5
      end
    end

    describe 'change migration' do

      class AddFoo < ACTIVE_RECORD_MIGRATION_CLASS
        def change
          create_table :foo do |t|
            t.timestamps
          end
        end
      end

      it 'runs migrate up with timeout' do
        migration = AddFoo.new
        expect_create_table
        expect(ActiveRecord::Base.connection).to receive(:execute).
          with("SET LOCAL lock_timeout = '5s'").
          and_call_original
        migration.migrate(:up)
      end

      it 'runs migrate down without timeout' do
        migration = AddFoo.new
        expect(ActiveRecord::Base.connection).not_to receive(:execute).
          with("SET LOCAL lock_timeout = '5s'")
        migration.migrate(:down)
      end

      it 'allows migration to run if no default timeout set' do
        MigrationLockTimeout.config = nil
        migration = AddFoo.new
        expect(ActiveRecord::Base.connection).not_to receive(:execute).
          with("SET LOCAL lock_timeout = '5s'")
        migration.migrate(:up)
      end
    end

    describe 'up / down migration' do

      class AddBar < ACTIVE_RECORD_MIGRATION_CLASS
        def up
          create_table :bar do |t|
            t.timestamps
          end
        end

        def down
          drop_table :bar
        end
      end

      it 'runs migrate up with timeout' do
        migration = AddBar.new
        expect_create_table
        expect(ActiveRecord::Base.connection).to receive(:execute).
          with("SET LOCAL lock_timeout = '5s'").
          and_call_original
        migration.migrate(:up)
      end

      it 'runs migrate down without timeout' do
        migration = AddBar.new
        expect(ActiveRecord::Base.connection).not_to receive(:execute).
          with("SET LOCAL lock_timeout = '5s'")
        migration.migrate(:down)
      end
    end

    describe 'disable lock timeout' do

      class AddBaz < ACTIVE_RECORD_MIGRATION_CLASS
        disable_lock_timeout!
        def up
          create_table :baz do |t|
            t.timestamps
          end
        end

        def down
          drop_table :baz
        end
      end

      it 'runs migrate up without timeout' do
        migration = AddBaz.new
        expect(ActiveRecord::Base.connection).not_to receive(:execute).
          with("SET LOCAL lock_timeout = '5s'")
        migration.migrate(:up)
      end

      it 'runs migrate down without timeout' do
        migration = AddBaz.new
        expect(ActiveRecord::Base.connection).not_to receive(:execute).
          with("SET LOCAL lock_timeout = '5s'")
        migration.migrate(:down)
      end
    end


    describe 'change lock timeout' do

      class AddBurn < ACTIVE_RECORD_MIGRATION_CLASS
        set_lock_timeout 10
        def up
          create_table :burn do |t|
            t.timestamps
          end
        end

        def down
          drop_table :burn
        end
      end

      it 'runs migrate up with timeout' do
        migration = AddBurn.new
        expect_create_table
        expect(ActiveRecord::Base.connection).to receive(:execute).
          with("SET LOCAL lock_timeout = '10s'").
          and_call_original
        migration.migrate(:up)
      end

      it 'runs migrate down without timeout' do
        migration = AddBurn.new
        expect(ActiveRecord::Base.connection).not_to receive(:execute).
          with("SET LOCAL lock_timeout = '10s'")
        migration.migrate(:down)
      end
    end

    describe 'with disable_ddl_transaction' do

      class AddMonkey < ACTIVE_RECORD_MIGRATION_CLASS
        disable_ddl_transaction!
        def up
          create_table :monkey do |t|
            t.timestamps
          end
        end

        def down
          drop_table :monkey
        end
      end

      it 'runs migrate up with session-level timeout' do
        migration = AddMonkey.new
        expect_create_table
        expect(ActiveRecord::Base.connection).to receive(:execute).
          with("SET lock_timeout = '5s'").
          and_call_original
        expect(ActiveRecord::Base.connection).to receive(:execute).
          with("RESET lock_timeout").
          and_call_original
        migration.migrate(:up)
      end

      it 'runs migrate down without timeout' do
        migration = AddMonkey.new
        expect(ActiveRecord::Base.connection).not_to receive(:execute).
          with("SET lock_timeout = '5s'")
        expect(ActiveRecord::Base.connection).not_to receive(:execute).
          with("RESET lock_timeout")
        migration.migrate(:down)
      end
    end

    describe 'disable lock timeout' do

      class AddBaz < ACTIVE_RECORD_MIGRATION_CLASS
        disable_lock_timeout!
        def up
          create_table :baz do |t|
            t.timestamps
          end
        end

        def down
          drop_table :baz
        end
      end

      it 'runs migrate up without timeout' do
        migration = AddBaz.new
        expect(ActiveRecord::Base.connection).not_to receive(:execute).
          with("SET LOCAL lock_timeout = '5s'")
        migration.migrate(:up)
      end

      it 'runs migrate down without timeout' do
        migration = AddBaz.new
        expect(ActiveRecord::Base.connection).not_to receive(:execute).
          with("SET LOCAL lock_timeout = '5s'")
        migration.migrate(:down)
      end
    end
  end

end
