# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation including README, API docs, architecture guide, deployment guide, database documentation, and contributing guidelines
- Fixed table name inconsistency in repository layer
- Added example usage and testing instructions
- Included Docker setup and deployment configurations

### Changed
- Improved error handling documentation
- Enhanced API endpoint documentation with detailed examples

### Fixed
- Table name inconsistency between `user` and `users` in repository queries

## [1.0.0] - 2024-01-XX

### Added
- Initial Go API implementation
- User management CRUD operations
- Clean architecture pattern implementation
- PostgreSQL database integration
- Docker and Docker Compose configuration
- Gin web framework integration
- Basic health check endpoint

### Features
- **GET /ping** - Health check endpoint
- **GET /users** - Retrieve all users
- **GET /user/:id** - Retrieve user by ID
- **POST /user** - Create new user

### Technical Stack
- Go 1.22.5
- Gin web framework
- PostgreSQL database
- Docker containerization
- Clean architecture pattern

### Architecture
- Controller layer for HTTP handling
- Usecase layer for business logic
- Repository layer for data access
- Model layer for domain entities
- Database connection management

---

## Release Notes Format

### Categories
- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

### Version Format
- Use [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH)
- MAJOR: Incompatible API changes
- MINOR: Backward-compatible functionality additions
- PATCH: Backward-compatible bug fixes