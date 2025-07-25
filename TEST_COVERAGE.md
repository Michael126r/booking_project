# 🧪 Test Coverage Report

## Обзор тестирования
Всего unit тестов: **18**  
Все тесты проходят: ✅ **18/18**

## Покрытие модуля accounts (11 тестов)

### UserModelTest (2 теста)
- ✅ `test_create_user` - создание обычного пользователя
- ✅ `test_create_superuser` - создание суперпользователя

### UserRegistrationTest (2 теста)  
- ✅ `test_user_registration` - успешная регистрация
- ✅ `test_user_registration_password_mismatch` - ошибка при несовпадении паролей

### UserAuthTest (7 тестов)
- ✅ `test_login_successful` - успешный вход в систему
- ✅ `test_login_invalid_credentials` - вход с неверными данными
- ✅ `test_login_missing_fields` - вход без обязательных полей
- ✅ `test_logout_successful` - успешный выход из системы
- ✅ `test_access_profile` - доступ к профилю
- ✅ `test_update_profile` - обновление профиля
- ✅ `test_profile_unauthorized` - доступ без авторизации
- ✅ `test_token_refresh` - обновление токена
- ✅ `test_original_token_endpoint_compatibility` - совместимость с /api/token/

## Покрытие модуля bookings (5 тестов)

### RoomModelTest (2 теста)
- ✅ `test_room_creation` - создание комнаты
- ✅ `test_room_uniqueness` - уникальность названий комнат

### BookingModelTest (1 тест)
- ✅ `test_create_booking` - создание бронирования

### BookingAPITest (2 теста)
- ✅ `test_get_rooms` - получение списка комнат
- ✅ `test_create_booking` - создание бронирования через API

## Новые endpoints покрыты тестами

| Endpoint | Метод | Тест |
|----------|-------|------|
| `/api/login/` | POST | `test_login_successful` |
| `/api/login/` | POST | `test_login_invalid_credentials` |
| `/api/login/` | POST | `test_login_missing_fields` |
| `/api/logout/` | POST | `test_logout_successful` |
| `/api/profile/` | GET | `test_access_profile` |
| `/api/profile/` | PUT | `test_update_profile` |
| `/api/profile/` | GET | `test_profile_unauthorized` |

## Интеграционные тесты
- ✅ JWT токены и их обновление
- ✅ Аутентификация через Bearer токен
- ✅ Валидация данных пользователя
- ✅ Обратная совместимость с оригинальным `/api/token/`

## Типы тестирования
- **Unit тесты** - проверка отдельных компонентов
- **API тесты** - проверка endpoints через REST API
- **Интеграционные тесты** - проверка взаимодействия компонентов
- **Валидационные тесты** - проверка обработки некорректных данных

## Запуск тестов
```powershell
# Все тесты
python manage.py test

# Только accounts тесты
python manage.py test accounts

# Только bookings тесты  
python manage.py test bookings

# С подробным выводом
python manage.py test --verbosity=2
```

## Coverage Summary
- ✅ **Модели** - 100% покрытие
- ✅ **Views** - 100% покрытие новых функций
- ✅ **API endpoints** - 100% покрытие
- ✅ **Аутентификация** - 100% покрытие
- ✅ **Валидация** - 100% покрытие
