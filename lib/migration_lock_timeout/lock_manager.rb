module MigrationLockTimeout
  module LockManager

    def migrate(direction)
      timeout_disabled = self.class.disable_lock_timeout
      time = self.class.lock_timeout_override ||
        MigrationLockTimeout.try(:config).try(:default_timeout)
      
      if !timeout_disabled && direction == :up && time
        safety_assured? do
          if disable_ddl_transaction
            # Use session-level timeout for non-transactional migrations
            execute "SET lock_timeout = '#{time}s'"
          else
            # Use transaction-level timeout for transactional migrations
            execute "SET LOCAL lock_timeout = '#{time}s'"
          end
        end
      end
      
      super
    ensure
      # Reset session-level timeout after non-transactional migrations
      if !timeout_disabled && direction == :up && time && disable_ddl_transaction
        safety_assured? do
          execute "RESET lock_timeout"
        end
      end
    end

    def safety_assured?
      if defined?(StrongMigrations)
        safety_assured { yield }
      else
        yield
      end
    end
  end
end
