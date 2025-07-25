# PostgreSQL setup script for Windows
# This script helps set up PostgreSQL database for the booking project

Write-Host "Setting up PostgreSQL for Booking Project" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Check if PostgreSQL is installed
try {
    $pgVersion = psql --version
    Write-Host "PostgreSQL found: $pgVersion" -ForegroundColor Yellow
} catch {
    Write-Host "PostgreSQL not found. Please install PostgreSQL first." -ForegroundColor Red
    Write-Host "Download from: https://www.postgresql.org/download/windows/" -ForegroundColor Blue
    exit 1
}

# Prompt for PostgreSQL superuser password
$pgPassword = Read-Host "Enter PostgreSQL superuser (postgres) password" -AsSecureString
$pgPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pgPassword))

# Create database
Write-Host "Creating database 'booking_db'..." -ForegroundColor Yellow
$env:PGPASSWORD = $pgPasswordPlain
try {
    psql -U postgres -c "CREATE DATABASE booking_db;"
    Write-Host "Database 'booking_db' created successfully!" -ForegroundColor Green
} catch {
    Write-Host "Database might already exist or there was an error." -ForegroundColor Yellow
}

# Install Python requirements
Write-Host "Installing Python requirements..." -ForegroundColor Yellow
pip install -r requirements.txt

# Run Django migrations
Write-Host "Running Django migrations..." -ForegroundColor Yellow
python manage.py makemigrations
python manage.py migrate

# Create superuser
Write-Host "Creating Django superuser..." -ForegroundColor Yellow
python manage.py createsuperuser

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "You can now run: python manage.py runserver" -ForegroundColor Blue

# Clean up
Remove-Variable pgPasswordPlain
$env:PGPASSWORD = $null
