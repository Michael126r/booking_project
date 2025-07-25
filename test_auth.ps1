Write-Host "=== Testing Login Functions ===" -ForegroundColor Green

# Запускаем сервер в фоне
Write-Host "`nStarting server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-Command", "cd 'C:\Users\Michael\booking_project'; python manage.py runserver" -WindowStyle Hidden
Start-Sleep -Seconds 3

Write-Host "`n1. Testing new login endpoint" -ForegroundColor Yellow
$loginData = @{
    email = "test@example.com"
    password = "testpass123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/login/" -Method POST -ContentType "application/json" -Body $loginData
    Write-Host "OK - Login successful" -ForegroundColor Green
    Write-Host "User: $($loginResponse.user.email)" -ForegroundColor White
    Write-Host "Access Token: $($loginResponse.access_token.Substring(0, 20))..." -ForegroundColor White
    $accessToken = $loginResponse.access_token
    $refreshToken = $loginResponse.refresh_token
} catch {
    Write-Host "ERROR - Login failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Testing profile endpoint" -ForegroundColor Yellow
try {
    $profile = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/profile/" -Headers @{Authorization="Bearer $accessToken"}
    Write-Host "OK - Profile retrieved" -ForegroundColor Green
    Write-Host "Profile: $($profile.user.email) ($($profile.user.username))" -ForegroundColor White
} catch {
    Write-Host "ERROR - Profile: $_" -ForegroundColor Red
}

Write-Host "`n3. Testing profile update" -ForegroundColor Yellow
$updateData = @{
    first_name = "Test"
    last_name = "User"
    phone = "+7-123-456-78-90"
    department = "IT Testing"
} | ConvertTo-Json

try {
    $updatedProfile = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/profile/" -Method PUT -Headers @{Authorization="Bearer $accessToken"} -ContentType "application/json" -Body $updateData
    Write-Host "OK - Profile updated" -ForegroundColor Green
    Write-Host "Name: $($updatedProfile.user.first_name) $($updatedProfile.user.last_name)" -ForegroundColor White
    Write-Host "Department: $($updatedProfile.user.department)" -ForegroundColor White
} catch {
    Write-Host "ERROR - Profile update: $_" -ForegroundColor Red
}

Write-Host "`n4. Testing rooms access with new token" -ForegroundColor Yellow
try {
    $rooms = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/rooms/" -Headers @{Authorization="Bearer $accessToken"}
    Write-Host "OK - Rooms accessible with login token" -ForegroundColor Green
    Write-Host "Room count: $($rooms.count)" -ForegroundColor White
} catch {
    Write-Host "ERROR - Rooms access: $_" -ForegroundColor Red
}

Write-Host "`n5. Testing logout" -ForegroundColor Yellow
$logoutData = @{
    refresh_token = $refreshToken
} | ConvertTo-Json

try {
    $logoutResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/logout/" -Method POST -Headers @{Authorization="Bearer $accessToken"} -ContentType "application/json" -Body $logoutData
    Write-Host "OK - Logout successful" -ForegroundColor Green
    Write-Host "Message: $($logoutResponse.message)" -ForegroundColor White
} catch {
    Write-Host "ERROR - Logout: $_" -ForegroundColor Red
}

Write-Host "`n6. Testing access after logout (should fail)" -ForegroundColor Yellow
try {
    $testAccess = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/profile/" -Headers @{Authorization="Bearer $accessToken"} -ErrorAction Stop
    Write-Host "WARNING - Access still works after logout (token not blacklisted)" -ForegroundColor Yellow
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "OK - Access properly denied after logout" -ForegroundColor Green
    } else {
        Write-Host "ERROR - Unexpected error: $_" -ForegroundColor Red
    }
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Green
Write-Host "`nNew endpoints available:" -ForegroundColor Cyan
Write-Host "- POST /api/login/ - Login with email/password" -ForegroundColor White
Write-Host "- POST /api/logout/ - Logout and blacklist token" -ForegroundColor White  
Write-Host "- GET /api/profile/ - Get user profile" -ForegroundColor White
Write-Host "- PUT /api/profile/ - Update user profile" -ForegroundColor White
