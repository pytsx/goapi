# Database Schema Documentation

## Overview

This document describes the database schema, table structures, relationships, and data management for the Go API project.

## Database Information

- **Database Management System**: PostgreSQL
- **Database Name**: `postgres` (configurable)
- **Character Set**: UTF-8
- **Connection Details**: Configured in `db/conn.go`

## Schema Design

### Current Schema Structure

The application currently uses a simple schema with a single table for user management:

```sql
-- Database: postgres
-- Schema: public (default)

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    img_url VARCHAR(255)
);
```

## Table Specifications

### users

**Purpose**: Stores user information for the application

| Column   | Type         | Constraints           | Description                    |
|----------|--------------|----------------------|--------------------------------|
| id       | SERIAL       | PRIMARY KEY          | Unique user identifier         |
| name     | VARCHAR(255) | NOT NULL             | User's full name               |
| email    | VARCHAR(255) | NOT NULL             | User's email address           |
| img_url  | VARCHAR(255) | NULL                 | URL to user's profile image    |

#### Column Details

**id (SERIAL PRIMARY KEY)**
- Auto-incrementing integer
- Starts at 1
- Unique identifier for each user
- Referenced in API responses as `user_id`

**name (VARCHAR(255) NOT NULL)**
- Required field
- Maximum length: 255 characters
- Stores user's full name or display name
- Should not be empty or whitespace only

**email (VARCHAR(255) NOT NULL)**
- Required field
- Maximum length: 255 characters
- Should contain valid email format
- Currently no uniqueness constraint (consider adding)

**img_url (VARCHAR(255))**
- Optional field
- Maximum length: 255 characters
- Stores URL to user's profile image
- Can be NULL or empty

## Data Types and Constraints

### Current Constraints

```sql
-- Primary key constraint
ALTER TABLE users ADD CONSTRAINT users_pkey PRIMARY KEY (id);

-- Not null constraints
ALTER TABLE users ALTER COLUMN name SET NOT NULL;
ALTER TABLE users ALTER COLUMN email SET NOT NULL;
```

### Recommended Additional Constraints

For production use, consider adding these constraints:

```sql
-- Email uniqueness constraint
ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);

-- Email format validation
ALTER TABLE users ADD CONSTRAINT users_email_format 
    CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Name length validation
ALTER TABLE users ADD CONSTRAINT users_name_length 
    CHECK (length(trim(name)) > 0);

-- URL format validation (optional)
ALTER TABLE users ADD CONSTRAINT users_img_url_format 
    CHECK (img_url IS NULL OR img_url ~ '^https?://.*');
```

## Indexes

### Current Indexes

```sql
-- Automatically created with PRIMARY KEY
CREATE UNIQUE INDEX users_pkey ON users (id);
```

### Recommended Additional Indexes

```sql
-- Index for email lookups (if implementing email-based queries)
CREATE INDEX idx_users_email ON users (email);

-- Index for name searches (if implementing name-based searches)
CREATE INDEX idx_users_name ON users (name);

-- Composite index for pagination queries
CREATE INDEX idx_users_id_name ON users (id, name);
```

## Database Operations

### Table Creation Script

```sql
-- Complete table creation with recommended constraints
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL CHECK (length(trim(name)) > 0),
    email VARCHAR(255) NOT NULL UNIQUE 
        CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    img_url VARCHAR(255) 
        CHECK (img_url IS NULL OR img_url ~ '^https?://.*'),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_created_at ON users (created_at);
```

### Sample Data

```sql
-- Insert sample users
INSERT INTO users (name, email, img_url) VALUES
    ('John Doe', 'john.doe@example.com', 'https://example.com/avatars/john.jpg'),
    ('Jane Smith', 'jane.smith@example.com', 'https://example.com/avatars/jane.jpg'),
    ('Bob Wilson', 'bob.wilson@example.com', NULL),
    ('Alice Johnson', 'alice.johnson@example.com', 'https://example.com/avatars/alice.jpg');
```

## Repository Layer Mapping

### Go Model to Database Mapping

```go
// model/user.go
type User struct {
    ID     int    `json:"user_id"`    // maps to: id
    Name   string `json:"name"`       // maps to: name
    Email  string `json:"email"`      // maps to: email
    ImgURL string `json:"img_url"`    // maps to: img_url
}
```

### SQL Queries Used

**Get All Users**:
```sql
SELECT id, name, email, img_url FROM users;
```

**Get User by ID**:
```sql
SELECT * FROM users WHERE id = $1;
```

**Create User**:
```sql
INSERT INTO user (user_name, user_email, user_imgurl) 
VALUES ($1, $2, $3) RETURNING user_id;
```

*Note: There's a discrepancy in the CREATE query column names that should be fixed*

### Repository Implementation Notes

The current repository implementation has some inconsistencies:

1. **Table Name Mismatch**: 
   - Create query uses `user` table
   - Select queries use `users` table
   - Should be standardized to `users`

2. **Column Name Mismatch**:
   - Create query uses `user_name, user_email, user_imgurl`
   - Select queries use `name, email, img_url`
   - Should be standardized

## Migration Scripts

### Initial Migration

```sql
-- V1__Create_users_table.sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    img_url VARCHAR(255)
);
```

### Migration V2 - Add Constraints

```sql
-- V2__Add_user_constraints.sql
ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);
ALTER TABLE users ADD CONSTRAINT users_email_format 
    CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
ALTER TABLE users ADD CONSTRAINT users_name_length 
    CHECK (length(trim(name)) > 0);
```

### Migration V3 - Add Timestamps

```sql
-- V3__Add_timestamps.sql
ALTER TABLE users ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE users ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

## Database Configuration

### Connection Settings

Current configuration in `db/conn.go`:

```go
const (
    host     = "godb"      // Docker service name
    port     = 5432        // Default PostgreSQL port
    user     = "postgres"  // Database user
    password = "1234"      // Database password (change for production)
    dbname   = "postgres"  // Database name
)
```

### Connection Pool Settings

Recommended connection pool configuration:

```go
func ConnectDB() (*sql.DB, error) {
    // ... connection setup
    
    db.SetMaxOpenConns(25)               // Maximum open connections
    db.SetMaxIdleConns(5)                // Maximum idle connections
    db.SetConnMaxLifetime(5 * time.Minute) // Connection lifetime
    
    return db, nil
}
```

## Backup and Recovery

### Backup Commands

```bash
# Full database backup
pg_dump -h localhost -U postgres -d postgres > backup.sql

# Schema-only backup
pg_dump -h localhost -U postgres -d postgres --schema-only > schema.sql

# Data-only backup
pg_dump -h localhost -U postgres -d postgres --data-only > data.sql

# Specific table backup
pg_dump -h localhost -U postgres -d postgres -t users > users_backup.sql
```

### Restore Commands

```bash
# Full restore
psql -h localhost -U postgres -d postgres < backup.sql

# Restore specific table
psql -h localhost -U postgres -d postgres < users_backup.sql
```

## Performance Considerations

### Query Performance

1. **Use Prepared Statements**: Already implemented in repository layer
2. **Limit Result Sets**: Consider adding pagination for large datasets
3. **Optimize Queries**: Use EXPLAIN ANALYZE to identify slow queries

### Index Strategy

```sql
-- For frequently accessed users
CREATE INDEX idx_users_active ON users (id) WHERE img_url IS NOT NULL;

-- For email-based lookups
CREATE INDEX idx_users_email_hash ON users USING hash (email);
```

### Connection Management

- Use connection pooling in production
- Monitor active connections
- Set appropriate timeout values

## Security Considerations

### Data Protection

1. **Email Validation**: Implement proper email format validation
2. **Input Sanitization**: Prevent SQL injection (using prepared statements)
3. **URL Validation**: Validate image URLs to prevent malicious links

### Access Control

```sql
-- Create application user with limited privileges
CREATE USER goapi_app WITH PASSWORD 'secure_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO goapi_app;
GRANT USAGE, SELECT ON SEQUENCE users_id_seq TO goapi_app;
```

## Future Schema Enhancements

### Potential Additions

1. **User Authentication**:
   ```sql
   ALTER TABLE users ADD COLUMN password_hash VARCHAR(255);
   ALTER TABLE users ADD COLUMN salt VARCHAR(255);
   ```

2. **User Status**:
   ```sql
   ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active';
   ALTER TABLE users ADD CONSTRAINT users_status_check 
       CHECK (status IN ('active', 'inactive', 'suspended'));
   ```

3. **User Roles**:
   ```sql
   CREATE TABLE roles (
       id SERIAL PRIMARY KEY,
       name VARCHAR(50) NOT NULL UNIQUE
   );
   
   ALTER TABLE users ADD COLUMN role_id INTEGER REFERENCES roles(id);
   ```

4. **Audit Trail**:
   ```sql
   CREATE TABLE user_audit (
       id SERIAL PRIMARY KEY,
       user_id INTEGER REFERENCES users(id),
       action VARCHAR(20) NOT NULL,
       changed_data JSONB,
       changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
       changed_by INTEGER REFERENCES users(id)
   );
   ```

This database documentation provides a comprehensive overview of the current schema and recommendations for improvements and production readiness.