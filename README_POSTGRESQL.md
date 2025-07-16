# PostgreSQL Setup for Booking Project

This project has been configured to use PostgreSQL instead of SQLite. Follow these steps to set up PostgreSQL for your booking project.

## Prerequisites

1. **Install PostgreSQL** (if not already installed):
   - Download from: https://www.postgresql.org/download/windows/
   - During installation, remember the password you set for the `postgres` user
   - Make sure to add PostgreSQL to your system PATH

2. **Verify PostgreSQL Installation**:
   ```powershell
   psql --version
   ```

## Setup Options

### Option 1: Automatic Setup (Recommended)

Run the provided PowerShell script:
```powershell
.\setup_postgresql.ps1
```

This script will:
- Check if PostgreSQL is installed
- Create the database
- Install Python requirements
- Run Django migrations
- Create Django superuser

### Option 2: Manual Setup

1. **Install Python Requirements**:
   ```powershell
   pip install -r requirements.txt
   ```

2. **Create PostgreSQL Database**:
   ```powershell
   psql -U postgres -c "CREATE DATABASE booking_db;"
   ```

3. **Configure Environment Variables**:
   - Edit the `.env` file with your PostgreSQL credentials
   - Default values are already set for local development

4. **Run Django Migrations**:
   ```powershell
   python manage.py makemigrations
   python manage.py migrate
   ```

5. **Create Django Superuser**:
   ```powershell
   python manage.py createsuperuser
   ```

## Environment Variables

The following environment variables are configured in the `.env` file:

```env
# Django settings
SECRET_KEY=django-insecure-change-me-in-production
DEBUG=True

# PostgreSQL database settings
DB_NAME=booking_db
DB_USER=postgres
DB_PASSWORD=password
DB_HOST=localhost
DB_PORT=5432
```

**Important**: Change the `DB_PASSWORD` in the `.env` file to match your PostgreSQL password.

## Database Configuration

The project now uses the following database settings:

- **Database Engine**: PostgreSQL
- **Database Name**: `booking_db`
- **User**: `postgres` (or configure a dedicated user)
- **Host**: `localhost`
- **Port**: `5432`

## Running the Project

After setup, you can run the project as usual:

```powershell
python manage.py runserver
```

## Troubleshooting

### Common Issues

1. **"psql: command not found"**:
   - Make sure PostgreSQL is installed and added to your PATH
   - Restart your terminal after installation

2. **Database connection errors**:
   - Check your PostgreSQL service is running
   - Verify credentials in the `.env` file
   - Ensure the database `booking_db` exists

3. **Permission errors**:
   - Make sure the PostgreSQL user has proper permissions
   - You might need to run PostgreSQL commands as administrator

### Database Management

To connect to your database directly:
```powershell
psql -U postgres -d booking_db
```

To backup your database:
```powershell
pg_dump -U postgres booking_db > backup.sql
```

To restore from backup:
```powershell
psql -U postgres booking_db < backup.sql
```

## Changes Made

The following files were modified to support PostgreSQL:

1. **requirements.txt**: Added `psycopg2-binary` and `python-decouple`
2. **settings.py**: 
   - Added PostgreSQL database configuration
   - Added environment variable support with `python-decouple`
3. **Added files**:
   - `.env`: Environment variables configuration
   - `setup_postgresql.sql`: SQL script for manual database setup
   - `setup_postgresql.ps1`: PowerShell script for automated setup
   - `README_POSTGRESQL.md`: This documentation

## Security Notes

- Change the `SECRET_KEY` in production
- Use strong passwords for database users
- Consider using environment variables for sensitive data
- The `.env` file should not be committed to version control (add it to `.gitignore`)
