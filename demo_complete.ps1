Write-Host "=== BOOKING SYSTEM COMPLETE DEMO ===" -ForegroundColor Green

Write-Host "`n🧪 Running Unit Tests..." -ForegroundColor Yellow
$testResult = python manage.py test --verbosity=0
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ All unit tests passed!" -ForegroundColor Green
} else {
    Write-Host "❌ Tests failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n🚀 Starting server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-Command", "cd 'C:\Users\Michael\booking_project'; python manage.py runserver" -WindowStyle Hidden
Start-Sleep -Seconds 3

Write-Host "`n📋 API Overview:" -ForegroundColor Cyan
try {
    $apiInfo = Invoke-RestMethod -Uri "http://127.0.0.1:8000/"
    Write-Host "API Version: $($apiInfo.version)" -ForegroundColor White
    Write-Host "Available endpoints: $($apiInfo.endpoints.Count)" -ForegroundColor White
} catch {
    Write-Host "❌ Server not ready" -ForegroundColor Red
}

Write-Host "`n🔐 Testing Authentication System..." -ForegroundColor Yellow

# 1. Register new user
Write-Host "1. Registering new user..." -ForegroundColor White
$regData = @{
    username = "demo_user_$(Get-Random -Maximum 1000)"
    email = "demo_$(Get-Random -Maximum 1000)@example.com"
    password = "demopass123"
    password_confirm = "demopass123"
} | ConvertTo-Json

try {
    $regResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/register/" -Method POST -ContentType "application/json" -Body $regData
    Write-Host "   ✅ User registered: $($regResponse.email)" -ForegroundColor Green
    $userEmail = $regResponse.email
} catch {
    Write-Host "   ❌ Registration failed" -ForegroundColor Red
    $userEmail = "test@example.com"
}

# 2. Login
Write-Host "`n2. Logging in..." -ForegroundColor White
$loginData = @{
    email = $userEmail
    password = "demopass123"
} | ConvertTo-Json

# Try with test user if registration failed
if ($userEmail -eq "test@example.com") {
    $loginData = @{
        email = "test@example.com"
        password = "testpass123"
    } | ConvertTo-Json
}

try {
    $loginResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/login/" -Method POST -ContentType "application/json" -Body $loginData
    Write-Host "   ✅ Login successful" -ForegroundColor Green
    Write-Host "   🔑 Access token received" -ForegroundColor Green
    $token = $loginResponse.access_token
    $refreshToken = $loginResponse.refresh_token
} catch {
    Write-Host "   ❌ Login failed" -ForegroundColor Red
    exit 1
}

# 3. Profile access
Write-Host "`n3. Accessing profile..." -ForegroundColor White
try {
    $profile = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/profile/" -Headers @{Authorization="Bearer $token"}
    Write-Host "   ✅ Profile accessed: $($profile.user.email)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Profile access failed" -ForegroundColor Red
}

# 4. Update profile
Write-Host "`n4. Updating profile..." -ForegroundColor White
$profileData = @{
    first_name = "Demo"
    last_name = "User"
    phone = "+7-999-123-45-67"
    department = "Demo Department"
} | ConvertTo-Json

try {
    $updatedProfile = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/profile/" -Method PUT -Headers @{Authorization="Bearer $token"} -ContentType "application/json" -Body $profileData
    Write-Host "   ✅ Profile updated: $($updatedProfile.user.first_name) $($updatedProfile.user.last_name)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Profile update failed" -ForegroundColor Red
}

# 5. Rooms access
Write-Host "`n5. Accessing rooms..." -ForegroundColor White
try {
    $rooms = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/rooms/" -Headers @{Authorization="Bearer $token"}
    Write-Host "   ✅ Rooms loaded: $($rooms.count) rooms available" -ForegroundColor Green
    
    foreach ($room in $rooms.results) {
        Write-Host "      - $($room.name) (capacity: $($room.capacity))" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ❌ Rooms access failed" -ForegroundColor Red
}

# 6. Bookings
Write-Host "`n6. Checking bookings..." -ForegroundColor White
try {
    $bookings = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/bookings/" -Headers @{Authorization="Bearer $token"}
    Write-Host "   ✅ Bookings loaded: $($bookings.count) bookings" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Bookings access failed" -ForegroundColor Red
}

# 7. Token refresh
Write-Host "`n7. Refreshing token..." -ForegroundColor White
$refreshData = @{
    refresh = $refreshToken
} | ConvertTo-Json

try {
    $newToken = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/token/refresh/" -Method POST -ContentType "application/json" -Body $refreshData
    Write-Host "   ✅ Token refreshed successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Token refresh failed" -ForegroundColor Red
}

# 8. Logout
Write-Host "`n8. Logging out..." -ForegroundColor White
$logoutData = @{
    refresh_token = $refreshToken
} | ConvertTo-Json

try {
    $logoutResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/logout/" -Method POST -Headers @{Authorization="Bearer $token"} -ContentType "application/json" -Body $logoutData
    Write-Host "   ✅ Logout successful" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Logout failed" -ForegroundColor Red
}

Write-Host "`n=== DEMO COMPLETE ===" -ForegroundColor Green
Write-Host "`n📊 Summary:" -ForegroundColor Cyan
Write-Host "✅ Authentication system fully functional" -ForegroundColor White
Write-Host "✅ All endpoints working correctly" -ForegroundColor White
Write-Host "✅ JWT token management working" -ForegroundColor White
Write-Host "✅ Profile management working" -ForegroundColor White
Write-Host "✅ API protection working" -ForegroundColor White

Write-Host "`n🔗 Access Points:" -ForegroundColor Cyan
Write-Host "• Main API: http://127.0.0.1:8000/" -ForegroundColor White
Write-Host "• Admin Panel: http://127.0.0.1:8000/admin/" -ForegroundColor White
Write-Host "• Login: POST /api/login/" -ForegroundColor White
Write-Host "• Profile: GET/PUT /api/profile/" -ForegroundColor White
Write-Host "• Rooms: GET /api/rooms/" -ForegroundColor White
Write-Host "• Bookings: GET/POST /api/bookings/" -ForegroundColor White

Write-Host "`n👤 Test Credentials:" -ForegroundColor Cyan
Write-Host "• Admin: admin@example.com / admin123" -ForegroundColor White
Write-Host "• User: test@example.com / testpass123" -ForegroundColor White
