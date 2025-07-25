Write-Host "=== Booking System API Test ===" -ForegroundColor Green

Write-Host "`n1. Testing root page" -ForegroundColor Yellow
try {
    $root = Invoke-RestMethod -Uri "http://127.0.0.1:8000/"
    Write-Host "OK - Root page works" -ForegroundColor Green
    Write-Host "Message: $($root.message)" -ForegroundColor White
} catch {
    Write-Host "ERROR - Root page: $_" -ForegroundColor Red
}

Write-Host "`n2. Testing admin" -ForegroundColor Yellow
try {
    $admin = Invoke-WebRequest -Uri "http://127.0.0.1:8000/admin/" -Method HEAD
    Write-Host "OK - Admin available (code: $($admin.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "ERROR - Admin: $_" -ForegroundColor Red
}

Write-Host "`n3. Testing API protection" -ForegroundColor Yellow
try {
    $rooms = Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/rooms/" -ErrorAction Stop
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "OK - API protected (401 Unauthorized)" -ForegroundColor Green
    } else {
        Write-Host "ERROR - Unexpected: $_" -ForegroundColor Red
    }
}

Write-Host "`n4. Testing login" -ForegroundColor Yellow
$loginData = @{
    email = "test@example.com"
    password = "testpass123"
} | ConvertTo-Json

try {
    $tokenResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/token/" -Method POST -ContentType "application/json" -Body $loginData
    Write-Host "OK - Token received" -ForegroundColor Green
    $token = $tokenResponse.access
} catch {
    Write-Host "ERROR - Token: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n5. Testing rooms API" -ForegroundColor Yellow
try {
    $rooms = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/rooms/" -Headers @{Authorization="Bearer $token"}
    Write-Host "OK - Rooms list received" -ForegroundColor Green
    Write-Host "Room count: $($rooms.count)" -ForegroundColor White
} catch {
    Write-Host "ERROR - Rooms: $_" -ForegroundColor Red
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Green
Write-Host "`nAccess info:" -ForegroundColor Cyan
Write-Host "Admin: http://127.0.0.1:8000/admin/" -ForegroundColor White
Write-Host "Login: admin@example.com" -ForegroundColor White
Write-Host "Password: admin123" -ForegroundColor White
Write-Host "API: http://127.0.0.1:8000/api/" -ForegroundColor White
Write-Host "Docs: http://127.0.0.1:8000/" -ForegroundColor White
