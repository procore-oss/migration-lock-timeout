# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - TBD
### Changed
- **BREAKING CHANGE**: Migrations using `disable_ddl_transaction!` now use session-level lock timeout (`SET lock_timeout`) instead of being skipped entirely. Previously, these migrations had no lock timeout applied. Now they will fail if they cannot acquire locks within the configured timeout period. This provides lock timeout protection for concurrent index creation and other non-transactional operations. The timeout is automatically reset after the migration completes.
  
  **Migration Guide**: If you have migrations using `disable_ddl_transaction!` that previously worked but may take longer than your configured timeout to acquire locks, you should either:
  - Use `disable_lock_timeout!` to explicitly disable the timeout for that migration
  - Use `set_lock_timeout <seconds>` to set a longer timeout for that specific migration
  - Adjust your default timeout configuration to accommodate these operations

## [1.5.0]
### Removed
- Dropped support for Rails 6.0 and earlier
- Dropped support for Ruby 3.0 and earlier

## [1.4.0]
### Added
- Support for Rails 7

## [1.3.0]
### Added
- Support for Rails 6

## [1.2.0]
### Added
- Support for using with the [strong_migrations](https://github.com/ankane/strong_migrations) gem
