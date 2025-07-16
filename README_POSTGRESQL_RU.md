# Настройка PostgreSQL для проекта бронирования

Этот проект настроен для использования PostgreSQL вместо SQLite. Следуйте данным инструкциям для настройки PostgreSQL в вашем проекте бронирования.

## Необходимые условия

1. **Установка PostgreSQL** (если еще не установлен):
   - Скачайте с: https://www.postgresql.org/download/windows/
   - Во время установки запомните пароль, который вы установили для пользователя `postgres`
   - Убедитесь, что PostgreSQL добавлен в системный PATH

2. **Проверка установки PostgreSQL**:
   ```powershell
   psql --version
   ```

## Варианты настройки

### Вариант 1: Автоматическая настройка (Рекомендуется)

Запустите предоставленный PowerShell скрипт:
```powershell
.\setup_postgresql.ps1
```

Этот скрипт выполнит следующие действия:
- Проверит установку PostgreSQL
- Создаст базу данных
- Установит зависимости Python
- Выполнит миграции Django
- Создаст суперпользователя Django

### Вариант 2: Ручная настройка

1. **Установка зависимостей Python**:
   ```powershell
   pip install -r requirements.txt
   ```

2. **Создание базы данных PostgreSQL**:
   ```powershell
   psql -U postgres -c "CREATE DATABASE booking_db;"
   ```

3. **Настройка переменных окружения**:
   - Отредактируйте файл `.env` с вашими данными PostgreSQL
   - Значения по умолчанию уже установлены для локальной разработки

4. **Выполнение миграций Django**:
   ```powershell
   python manage.py makemigrations
   python manage.py migrate
   ```

5. **Создание суперпользователя Django**:
   ```powershell
   python manage.py createsuperuser
   ```

## Переменные окружения

Следующие переменные окружения настроены в файле `.env`:

```env
# Настройки Django
SECRET_KEY=django-insecure-change-me-in-production
DEBUG=True

# Настройки базы данных PostgreSQL
DB_NAME=booking_db
DB_USER=postgres
DB_PASSWORD=password
DB_HOST=localhost
DB_PORT=5432
```

**Важно**: Измените `DB_PASSWORD` в файле `.env` на ваш пароль PostgreSQL.

## Конфигурация базы данных

Проект теперь использует следующие настройки базы данных:

- **Движок базы данных**: PostgreSQL
- **Имя базы данных**: `booking_db`
- **Пользователь**: `postgres` (или настройте отдельного пользователя)
- **Хост**: `localhost`
- **Порт**: `5432`

## Запуск проекта

После настройки вы можете запустить проект обычным способом:

```powershell
python manage.py runserver
```

## Решение проблем

### Частые проблемы

1. **"psql: command not found"**:
   - Убедитесь, что PostgreSQL установлен и добавлен в PATH
   - Перезапустите терминал после установки

2. **Ошибки подключения к базе данных**:
   - Проверьте, что служба PostgreSQL запущена
   - Проверьте учетные данные в файле `.env`
   - Убедитесь, что база данных `booking_db` существует

3. **Ошибки разрешений**:
   - Убедитесь, что пользователь PostgreSQL имеет необходимые разрешения
   - Возможно, потребуется запустить команды PostgreSQL от имени администратора

### Управление базой данных

Подключение к базе данных напрямую:
```powershell
psql -U postgres -d booking_db
```

Создание резервной копии базы данных:
```powershell
pg_dump -U postgres booking_db > backup.sql
```

Восстановление из резервной копии:
```powershell
psql -U postgres booking_db < backup.sql
```

## Полезные команды PostgreSQL

### Вход в PostgreSQL
```powershell
psql -U postgres
```

### Просмотр всех баз данных
```sql
\l
```

### Подключение к базе данных
```sql
\c booking_db
```

### Просмотр всех таблиц
```sql
\dt
```

### Выход из PostgreSQL
```sql
\q
```

### Создание нового пользователя (опционально)
```sql
CREATE USER booking_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE booking_db TO booking_user;
```

## Внесенные изменения

Следующие файлы были изменены для поддержки PostgreSQL:

1. **requirements.txt**: Добавлены `psycopg2-binary` и `python-decouple`
2. **settings.py**: 
   - Добавлена конфигурация PostgreSQL
   - Добавлена поддержка переменных окружения с помощью `python-decouple`
3. **Добавленные файлы**:
   - `.env`: Конфигурация переменных окружения
   - `setup_postgresql.sql`: SQL скрипт для ручной настройки базы данных
   - `setup_postgresql.ps1`: PowerShell скрипт для автоматической настройки
   - `README_POSTGRESQL_RU.md`: Данная документация

## Примеры использования

### Создание тестовых данных
```powershell
python manage.py create_test_data
```

### Создание администратора
```powershell
python manage.py create_admin
```

### Запуск тестов
```powershell
python manage.py test
```

## Рекомендации по безопасности

- Измените `SECRET_KEY` в продакшене
- Используйте надежные пароли для пользователей базы данных
- Рассмотрите возможность использования переменных окружения для чувствительных данных
- Файл `.env` не должен попадать в систему контроля версий (добавьте его в `.gitignore`)

## Дополнительные расширения PostgreSQL

В скрипте `setup_postgresql.sql` включены полезные расширения:

- `uuid-ossp`: Для генерации UUID
- `pgcrypto`: Для криптографических функций

Вы можете добавить другие расширения по необходимости.

## Производительность

Для улучшения производительности PostgreSQL рекомендуется:

1. Создать индексы для часто используемых полей
2. Настроить параметры конфигурации PostgreSQL
3. Использовать пул соединений для продакшена

## Мониторинг

Для мониторинга PostgreSQL можно использовать:

- `pg_stat_activity` - активные соединения
- `pg_stat_database` - статистика базы данных
- Логи PostgreSQL для отладки

## Поддержка

Если у вас возникли проблемы с настройкой PostgreSQL:

1. Проверьте логи PostgreSQL
2. Убедитесь, что все зависимости установлены
3. Проверьте конфигурацию в файле `.env`
4. Обратитесь к официальной документации PostgreSQL
