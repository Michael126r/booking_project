Write-Host "=== LOGIN API TESTING ===" -ForegroundColor Green

Write-Host "`n❌ Testing incorrect method (GET):" -ForegroundColor Red
try {
    $getResult = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/login/" -Method GET
} catch {
    Write-Host "Expected error received:" -ForegroundColor Yellow
    $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "Error: $($errorResponse.error)" -ForegroundColor White
    Write-Host "Message: $($errorResponse.message)" -ForegroundColor White
    Write-Host "Required method: $($errorResponse.usage.method)" -ForegroundColor White
}

Write-Host "`n✅ Testing correct method (POST):" -ForegroundColor Green
try {
    $loginData = @{
        email = "test@example.com"
        password = "testpass123"
    } | ConvertTo-Json

    $loginResult = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/login/" -Method POST -ContentType "application/json" -Body $loginData
    
    Write-Host "✅ Login successful!" -ForegroundColor Green
    Write-Host "Message: $($loginResult.message)" -ForegroundColor White
    Write-Host "User: $($loginResult.user.email)" -ForegroundColor White
    Write-Host "Token received: $($loginResult.access_token.Substring(0, 20))..." -ForegroundColor White
    
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n💡 How to use /api/login/ correctly:" -ForegroundColor Cyan

Write-Host "`n🔧 PowerShell example:" -ForegroundColor Yellow
Write-Host @"
`$loginData = @{
    email = "test@example.com"
    password = "testpass123"
} | ConvertTo-Json

`$response = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/login/" -Method POST -ContentType "application/json" -Body `$loginData
"@ -ForegroundColor White

Write-Host "`n🔧 cURL example:" -ForegroundColor Yellow
Write-Host @"
curl -X POST http://127.0.0.1:8000/api/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}'
"@ -ForegroundColor White

Write-Host "`n🔧 JavaScript fetch example:" -ForegroundColor Yellow
Write-Host @"
fetch('http://127.0.0.1:8000/api/login/', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    email: 'test@example.com',
    password: 'testpass123'
  })
})
.then(response => response.json())
.then(data => console.log('Success:', data));
"@ -ForegroundColor White

Write-Host "`n🔑 Available test credentials:" -ForegroundColor Cyan
Write-Host "• Admin: admin@example.com / admin123" -ForegroundColor White
Write-Host "• User: test@example.com / testpass123" -ForegroundColor White

Write-Host "`n📋 Common mistakes:" -ForegroundColor Red
Write-Host "❌ Using GET instead of POST" -ForegroundColor White
Write-Host "❌ Missing Content-Type: application/json header" -ForegroundColor White
Write-Host "❌ Incorrect JSON format in body" -ForegroundColor White
Write-Host "❌ Missing email or password fields" -ForegroundColor White
