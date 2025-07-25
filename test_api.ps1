# Тестирование Booking System API
Write-Host "=== Тестирование Booking System API ===" -ForegroundColor Green

# 1. Корневая страница
Write-Host "`n1. Проверка корневой страницы /" -ForegroundColor Yellow
try {
    $root = Invoke-RestMethod -Uri "http://127.0.0.1:8000/"
    Write-Host "✅ Корневая страница работает" -ForegroundColor Green
    Write-Host "Сообщение: $($root.message)" -ForegroundColor White
} catch {
    Write-Host "❌ Ошибка корневой страницы: $_" -ForegroundColor Red
}

# 2. Админка
Write-Host "`n2. Проверка админки /admin/" -ForegroundColor Yellow
try {
    $admin = Invoke-WebRequest -Uri "http://127.0.0.1:8000/admin/" -Method HEAD
    Write-Host "✅ Админка доступна (код: $($admin.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка админки: $_" -ForegroundColor Red
}

# 3. API без токена (должен возвращать 401)
Write-Host "`n3. Проверка защищенного API /api/rooms/ (без токена)" -ForegroundColor Yellow
try {
    $rooms = Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/rooms/" -ErrorAction Stop
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "✅ API правильно защищен (401 Unauthorized)" -ForegroundColor Green
    } else {
        Write-Host "❌ Неожиданная ошибка: $_" -ForegroundColor Red
    }
}

# 4. Регистрация нового пользователя
Write-Host "`n4. Регистрация нового пользователя" -ForegroundColor Yellow
$randomUser = "testuser_$(Get-Random -Maximum 1000)"
$regData = @{
    username = $randomUser
    email = "$randomUser@example.com"
    password = "testpass123"
    password_confirm = "testpass123"
} | ConvertTo-Json

try {
    $regResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/register/" -Method POST -ContentType "application/json" -Body $regData
    Write-Host "✅ Регистрация успешна" -ForegroundColor Green
    Write-Host "Пользователь: $($regResponse.email)" -ForegroundColor White
    $testEmail = $regResponse.email
} catch {
    Write-Host "❌ Ошибка регистрации: $_" -ForegroundColor Red
    $testEmail = "test@example.com"  # fallback к существующему пользователю
}

# 5. Получение токена
Write-Host "`n5. Получение JWT токена" -ForegroundColor Yellow
$loginData = @{
    email = $testEmail
    password = "testpass123"
} | ConvertTo-Json

try {
    $tokenResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/token/" -Method POST -ContentType "application/json" -Body $loginData
    Write-Host "✅ Токен получен" -ForegroundColor Green
    $token = $tokenResponse.access
    Write-Host "Токен начинается с: $($token.Substring(0, 20))..." -ForegroundColor White
} catch {
    Write-Host "❌ Ошибка получения токена: $_" -ForegroundColor Red
    exit 1
}

# 6. Получение списка комнат с токеном
Write-Host "`n6. Получение списка комнат с токеном" -ForegroundColor Yellow
try {
    $rooms = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/rooms/" -Headers @{Authorization="Bearer $token"}
    Write-Host "✅ Список комнат получен" -ForegroundColor Green
    Write-Host "Количество комнат: $($rooms.count)" -ForegroundColor White
    foreach ($room in $rooms.results) {
        Write-Host "  - $($room.name) (вместимость: $($room.capacity))" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Ошибка получения комнат: $_" -ForegroundColor Red
}

# 7. Получение бронирований пользователя
Write-Host "`n7. Получение бронирований пользователя" -ForegroundColor Yellow
try {
    $bookings = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/bookings/" -Headers @{Authorization="Bearer $token"}
    Write-Host "✅ Бронирования получены" -ForegroundColor Green
    Write-Host "Количество бронирований: $($bookings.count)" -ForegroundColor White
} catch {
    Write-Host "❌ Ошибка получения бронирований: $_" -ForegroundColor Red
}

Write-Host "`n=== Тестирование завершено ===" -ForegroundColor Green
Write-Host "`nДля доступа к системе используйте:" -ForegroundColor Cyan
Write-Host "Admin: http://127.0.0.1:8000/admin/" -ForegroundColor White
Write-Host "Login: admin@example.com" -ForegroundColor White
Write-Host "Password: admin123" -ForegroundColor White
Write-Host "API: http://127.0.0.1:8000/api/" -ForegroundColor White
Write-Host "Docs: http://127.0.0.1:8000/" -ForegroundColor White
