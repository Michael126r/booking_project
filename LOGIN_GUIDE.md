# 🔐 Руководство по аутентификации

## Новые endpoints для аутентификации

### 1. Логин `/api/login/`
**POST** запрос для входа в систему

```json
// Запрос
{
  "email": "test@example.com",
  "password": "testpass123"
}

// Ответ
{
  "message": "Успешная авторизация",
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": 2,
    "email": "test@example.com",
    "username": "test_user",
    "first_name": "Test",
    "last_name": "User",
    "department": "IT Testing",
    "phone": "+7-123-456-78-90"
  }
}
```

### 2. Профиль пользователя `/api/profile/`

#### GET - получить профиль
```http
GET /api/profile/
Authorization: Bearer <access_token>
```

#### PUT - обновить профиль
```json
// Запрос
{
  "first_name": "Новое имя",
  "last_name": "Новая фамилия", 
  "phone": "+7-999-123-45-67",
  "department": "Новый отдел"
}
```

### 3. Выход из системы `/api/logout/`
**POST** запрос для выхода и блокировки токена

```json
// Запрос
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

## Примеры использования

### PowerShell/Windows
```powershell
# Логин
$loginData = @{
    email = "test@example.com"
    password = "testpass123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/login/" -Method POST -ContentType "application/json" -Body $loginData
$token = $response.access_token

# Использование токена
$profile = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/profile/" -Headers @{Authorization="Bearer $token"}
```

### cURL
```bash
# Логин
curl -X POST http://127.0.0.1:8000/api/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}'

# Использование токена
curl -H "Authorization: Bearer <access_token>" \
  http://127.0.0.1:8000/api/profile/
```

### JavaScript/Fetch
```javascript
// Логин
const response = await fetch('http://127.0.0.1:8000/api/login/', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({
    email: 'test@example.com',
    password: 'testpass123'
  })
});

const data = await response.json();
const token = data.access_token;

// Использование токена
const profile = await fetch('http://127.0.0.1:8000/api/profile/', {
  headers: {'Authorization': `Bearer ${token}`}
});
```

## Все доступные endpoints

| Endpoint | Метод | Описание | Авторизация |
|----------|-------|----------|-------------|
| `/api/register/` | POST | Регистрация | Нет |
| `/api/login/` | POST | Логин | Нет |
| `/api/logout/` | POST | Выход | Да |
| `/api/profile/` | GET | Получить профиль | Да |
| `/api/profile/` | PUT | Обновить профиль | Да |
| `/api/rooms/` | GET | Список комнат | Да |
| `/api/bookings/` | GET/POST | Бронирования | Да |
| `/admin/` | - | Админ-панель | Нет |

## Тестовые учетные данные

- **Администратор:** admin@example.com / admin123
- **Тестовый пользователь:** test@example.com / testpass123

## Запуск тестов
```powershell
# Полный тест API
.\simple_test.ps1

# Тест функций аутентификации
.\test_auth.ps1
```
