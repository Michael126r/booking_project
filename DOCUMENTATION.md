# Документация проекта бронирования

## Обзор

Этот проект представляет собой Django REST API для системы бронирования переговорных комнат с JWT аутентификацией.

## Доступные файлы документации

### Основная документация
- **`README.md`** - Основное руководство по проекту (русский язык)
  - Описание возможностей
  - Инструкции по установке
  - API endpoints
  - Примеры использования

### Документация по базе данных

#### PostgreSQL
- **`README_POSTGRESQL.md`** - Руководство по настройке PostgreSQL (английский язык)
- **`README_POSTGRESQL_RU.md`** - Руководство по настройке PostgreSQL (русский язык)

Оба файла содержат:
- Автоматический и ручной способы настройки
- Решение проблем
- Полезные команды PostgreSQL
- Рекомендации по безопасности

### Файлы конфигурации

#### Переменные окружения
- **`.env`** - Файл с переменными окружения (не попадает в Git)
- **`.env.example`** - Пример файла переменных окружения

#### Скрипты настройки
- **`setup_postgresql.sql`** - SQL скрипт для ручной настройки PostgreSQL
- **`setup_postgresql.ps1`** - PowerShell скрипт для автоматической настройки PostgreSQL

## Быстрый старт

### Для SQLite (по умолчанию)
```bash
pip install -r requirements.txt
python manage.py migrate
python manage.py create_admin
python manage.py create_test_data
python manage.py runserver
```

### Для PostgreSQL
```bash
# Автоматическая настройка (Windows)
.\setup_postgresql.ps1

# Или следуйте инструкциям в README_POSTGRESQL_RU.md
```

## Тестовые данные

После запуска `python manage.py create_test_data` будут созданы:
- Администратор: `admin@example.com` / `admin123`
- Тестовый пользователь: `test@example.com` / `testpass123`

## Структура проекта

```
booking_project/
├── accounts/              # Приложение для пользователей
├── bookings/             # Приложение для бронирований
├── booking_project/      # Основной проект Django
├── requirements.txt      # Зависимости Python
├── manage.py            # Скрипт управления Django
├── README.md            # Основная документация
├── README_POSTGRESQL.md # Документация PostgreSQL (EN)
├── README_POSTGRESQL_RU.md # Документация PostgreSQL (RU)
├── .env                 # Переменные окружения
├── .env.example         # Пример переменных окружения
├── setup_postgresql.sql # SQL скрипт настройки
├── setup_postgresql.ps1 # PowerShell скрипт настройки
└── DOCUMENTATION.md     # Этот файл
```

## API Endpoints

### Аутентификация
- `POST /api/register/` - Регистрация пользователя
- `POST /api/token/` - Получение JWT токена
- `POST /api/token/refresh/` - Обновление JWT токена

### Комнаты
- `GET /api/rooms/` - Список всех комнат
- `GET /api/rooms/{id}/` - Детали комнаты
- `GET /api/rooms/{id}/availability/?date=YYYY-MM-DD` - Доступность комнаты

### Бронирования
- `GET /api/bookings/` - Список бронирований пользователя
- `POST /api/bookings/` - Создание бронирования
- `GET /api/bookings/{id}/` - Детали бронирования
- `PUT /api/bookings/{id}/` - Обновление бронирования
- `DELETE /api/bookings/{id}/` - Удаление бронирования
- `POST /api/bookings/{id}/cancel/` - Отмена бронирования

## Технологии

- Django 5.2
- Django REST Framework
- SimpleJWT
- SQLite (по умолчанию) / PostgreSQL (опционально)
- Python 3.8+

## Поддержка

Для получения помощи:
1. Проверьте соответствующую документацию
2. Убедитесь, что все зависимости установлены
3. Проверьте логи Django и базы данных
4. Обратитесь к официальной документации Django
