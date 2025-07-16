-- PostgreSQL database setup script
-- Run this script as PostgreSQL superuser (postgres)

-- Create database
CREATE DATABASE booking_db;

-- Create user (optional, if you want a dedicated user)
-- CREATE USER booking_user WITH PASSWORD 'your_password';

-- Grant privileges to user (optional)
-- GRANT ALL PRIVILEGES ON DATABASE booking_db TO booking_user;

-- Connect to the database
\c booking_db;

-- Create extensions that might be useful
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
