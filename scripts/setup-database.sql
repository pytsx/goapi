-- Database setup script for Go API
-- This script creates the users table with proper constraints

-- Create the users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL CHECK (length(trim(name)) > 0),
    email VARCHAR(255) NOT NULL UNIQUE 
        CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    img_url VARCHAR(255) 
        CHECK (img_url IS NULL OR img_url ~ '^https?://.*'),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users (created_at);

-- Create trigger for updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop trigger if exists and create new one
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data (optional)
INSERT INTO users (name, email, img_url) VALUES
    ('John Doe', 'john.doe@example.com', 'https://example.com/avatars/john.jpg'),
    ('Jane Smith', 'jane.smith@example.com', 'https://example.com/avatars/jane.jpg'),
    ('Bob Wilson', 'bob.wilson@example.com', NULL),
    ('Alice Johnson', 'alice.johnson@example.com', 'https://example.com/avatars/alice.jpg')
ON CONFLICT (email) DO NOTHING;

-- Display table information
\d users;

-- Show sample data
SELECT id, name, email, created_at FROM users LIMIT 5;