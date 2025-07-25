Write-Host "=== LOGIN API TESTING ===" -ForegroundColor Green

Write-Host "`nTesting incorrect method (GET):" -ForegroundColor Red
try {
    Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/login/" -Method GET
} catch {
    Write-Host "Expected 405 error received - GET not allowed" -ForegroundColor Yellow
    if ($_.ErrorDetails.Message) {
        $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Error: $($errorResponse.error)" -ForegroundColor White
        Write-Host "Solution: $($errorResponse.message)" -ForegroundColor White
    }
}

Write-Host "`nTesting correct method (POST):" -ForegroundColor Green
try {
    $loginData = @{
        email = "test@example.com"
        password = "testpass123"
    } | ConvertTo-Json

    $loginResult = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/login/" -Method POST -ContentType "application/json" -Body $loginData
    
    Write-Host "SUCCESS: Login worked!" -ForegroundColor Green
    Write-Host "Message: $($loginResult.message)" -ForegroundColor White
    Write-Host "User: $($loginResult.user.email)" -ForegroundColor White
    Write-Host "Token received: YES" -ForegroundColor White
    
} catch {
    Write-Host "FAILED: Login failed - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nHow to use /api/login/ correctly:" -ForegroundColor Cyan
Write-Host "Method: POST" -ForegroundColor White
Write-Host "URL: http://127.0.0.1:8000/api/login/" -ForegroundColor White
Write-Host "Content-Type: application/json" -ForegroundColor White
Write-Host "Body: {`"email`":`"test@example.com`",`"password`":`"testpass123`"}" -ForegroundColor White

Write-Host "`nTest credentials:" -ForegroundColor Cyan
Write-Host "Admin: admin@example.com / admin123" -ForegroundColor White
Write-Host "User: test@example.com / testpass123" -ForegroundColor White

Write-Host "`nCommon mistakes:" -ForegroundColor Red
Write-Host "- Using GET instead of POST" -ForegroundColor White
Write-Host "- Missing Content-Type header" -ForegroundColor White
Write-Host "- Wrong JSON format" -ForegroundColor White
Write-Host "- Missing email or password" -ForegroundColor White
