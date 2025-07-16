# API Бронирования Переговорных Комнат

Django REST API для системы бронирования переговорных комнат с JWT аутентификацией.

## Возможности

- 🔐 JWT аутентификация
- 👥 Регистрация и управление пользователями
- 🏢 Управление переговорными комнатами
- 📅 Бронирование комнат с проверкой конфликтов
- 🔍 Проверка доступности комнат
- 📊 Фильтрация и пагинация

## Установка

1. Создайте виртуальное окружение:
```bash
python -m venv venv
venv\Scripts\activate
```

2. Установите зависимости:
```bash
pip install -r requirements.txt
```

3. Проект использует SQLite по умолчанию. Для перехода на PostgreSQL следуйте инструкции в файле "README_POSTGRESQL.md" (или "README_POSTGRESQL_RU.md" для русской версии)

4. Выполните миграции:
```bash
python manage.py makemigrations
python manage.py migrate
```

5. Создайте суперпользователя:
```bash
python manage.py createsuperuser
```

6. Создайте тестовые данные (опционально):
```bash
python manage.py create_test_data
```

7. Запустите сервер:
```bash
python manage.py runserver
```

## API Endpoints

### Аутентификация
- `POST /api/register/` - Регистрация пользователя
- `POST /api/token/` - Получение JWT токена
- `POST /api/token/refresh/` - Обновление JWT токена

### Комнаты
- `GET /api/rooms/` - Список всех комнат
- `GET /api/rooms/{id}/` - Детали комнаты
- `GET /api/rooms/{id}/availability/?date=YYYY-MM-DD` - Доступность комнаты на дату

### Бронирования
- `GET /api/bookings/` - Список бронирований пользователя
- `POST /api/bookings/` - Создание бронирования
- `GET /api/bookings/{id}/` - Детали бронирования
- `PUT /api/bookings/{id}/` - Обновление бронирования
- `DELETE /api/bookings/{id}/` - Удаление бронирования
- `POST /api/bookings/{id}/cancel/` - Отмена бронирования
- `GET /api/bookings/my_bookings/` - Мои бронирования с фильтрацией

## Использование

### Регистрация пользователя
```bash
curl -X POST http://localhost:8000/api/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "securepassword123",
    "password_confirm": "securepassword123"
  }'
```

### Получение токена
```bash
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "securepassword123"
  }'
```

### Создание бронирования
```bash
curl -X POST http://localhost:8000/api/bookings/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "room": 1,
    "start_time": "2024-01-15T10:00:00Z",
    "end_time": "2024-01-15T11:00:00Z",
    "purpose": "Встреча с командой"
  }'
```

## Быстрый старт

Для быстрого тестирования API:

1. Установите зависимости: `pip install -r requirements.txt`
2. Выполните миграции: `python manage.py migrate`
3. Создайте админа: `python manage.py create_admin`
4. Создайте тестовые данные: `python manage.py create_test_data`
5. Запустите сервер: `python manage.py runserver`

**Тестовые данные:**
- Администратор: `admin@example.com` / `admin123`
- Тестовый пользователь: `test@example.com` / `testpass123`

## Настройка PostgreSQL

Для использования PostgreSQL вместо SQLite:

Для перехода на PostgreSQL следуйте шагам, описанным в:
- "README_POSTGRESQL.md" (английская версия)
- "README_POSTGRESQL_RU.md" (русская версия)

Эти руководства включают автоматический и ручной способы настройки PostgreSQL.

## Тестирование

Запуск всех тестов:
```bash
python manage.py test
```

## Технологии

- Django 5.2
- Django REST Framework
- SimpleJWT
- PostgreSQL (по умолчанию) / SQLite (опционально)
- Python 3.8+
