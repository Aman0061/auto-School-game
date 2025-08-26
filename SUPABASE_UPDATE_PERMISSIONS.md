# Настройка прав доступа в Supabase для обновления пользователей

## Проблема
Пользователи не могут обновлять свои данные в базе данных Supabase из-за ограничений Row Level Security (RLS).

## Решение
Выполните следующие SQL-команды в Supabase SQL Editor:

### 1. Включение RLS для таблицы users
```sql
-- Включаем Row Level Security для таблицы users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
```

### 2. Создание политики для обновления пользователей
```sql
4
```

### 5. Проверка существующих политик
```sql
-- Проверяем существующие политики для таблицы users
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'users';
```

### 6. Удаление старых политик (если нужно)
```sql
-- Удаляем старые политики, если они конфликтуют
DROP POLICY IF EXISTS "Users can update their own data" ON users;
DROP POLICY IF EXISTS "Users can read their own data" ON users;
DROP POLICY IF EXISTS "Users can insert their own data" ON users;
```

### 7. Проверка структуры таблицы users
```sql
-- Проверяем структуру таблицы users
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;
```

### 8. Тестовый запрос для проверки обновления
```sql
-- Тестовый запрос для проверки обновления (замените 'test_user_id' на реальный ID)
UPDATE users 
SET name = 'Test Updated Name', 
    email = 'test_updated@example.com',
    updated_at = NOW()
WHERE id = 'test_user_id';

-- Проверяем результат
SELECT id, name, email, phone, user_type, updated_at
FROM users 
WHERE id = 'test_user_id';
```

## Альтернативное решение (если RLS не нужен)
Если вы хотите отключить RLS для таблицы users:

```sql
-- Отключаем RLS для таблицы users (НЕ РЕКОМЕНДУЕТСЯ для продакшена)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```

## Проверка в приложении
После выполнения этих команд:

1. Попробуйте обновить профиль в приложении
2. Проверьте логи в консоли Flutter для отладочной информации
3. Проверьте таблицу users в Supabase Dashboard

## Возможные проблемы и решения

### Проблема: 403 Forbidden
**Решение:** Проверьте политики RLS и убедитесь, что они разрешают обновление

### Проблема: 404 Not Found
**Решение:** Проверьте, что ID пользователя существует в базе данных

### Проблема: 500 Internal Server Error
**Решение:** Проверьте структуру таблицы и типы данных

## Дополнительная отладка
Добавьте в Supabase Dashboard → Logs для просмотра детальных логов запросов.
