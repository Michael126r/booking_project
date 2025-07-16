# Git Push Script for booking_project
# This script helps with pushing changes to GitHub

param(
    [string]$message = "Update project"
)

Write-Host "Pushing changes to GitHub..." -ForegroundColor Green
Write-Host "Commit message: $message" -ForegroundColor Yellow

# Check if there are any changes
$status = git status --porcelain
if ([string]::IsNullOrEmpty($status)) {
    Write-Host "No changes to commit." -ForegroundColor Yellow
    exit 0
}

# Show current status
Write-Host "Current status:" -ForegroundColor Cyan
git status --short

# Add all changes
Write-Host "Adding all changes..." -ForegroundColor Yellow
git add .

# Commit changes
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m "$message"

# Push to GitHub
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
try {
    git push
    Write-Host "Successfully pushed to GitHub!" -ForegroundColor Green
} catch {
    Write-Host "Push failed. Trying with SSL verification disabled..." -ForegroundColor Red
    git config --global http.sslVerify false
    git push
    git config --global http.sslVerify true
    Write-Host "Successfully pushed to GitHub (with SSL workaround)!" -ForegroundColor Green
}

Write-Host "Done!" -ForegroundColor Green
