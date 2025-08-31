-- SQL скрипт для обновления таблицы users
-- Добавляем поле username и удаляем поля email и phone

-- 1. Добавляем поле username
ALTER TABLE users ADD COLUMN IF NOT EXISTS username TEXT;

-- 2. Создаем уникальный индекс для username
CREATE UNIQUE INDEX IF NOT EXISTS users_username_unique ON users(username);

-- 3. Обновляем существующие записи, генерируя уникальные логины
UPDATE users 
SET username = 'user_' || id::text 
WHERE username IS NULL;

-- 4. Делаем поле username обязательным
ALTER TABLE users ALTER COLUMN username SET NOT NULL;

-- 5. Делаем поля email и phone необязательными (временно)
-- Это нужно для совместимости с существующими данными
ALTER TABLE users ALTER COLUMN phone DROP NOT NULL;
ALTER TABLE users ALTER COLUMN email DROP NOT NULL;

-- 6. Удаляем поля email и phone (если они существуют)
-- ВНИМАНИЕ: Эти команды удалят данные! Выполняйте только если уверены!
-- ALTER TABLE users DROP COLUMN IF EXISTS email;
-- ALTER TABLE users DROP COLUMN IF EXISTS phone;

-- 7. Проверяем структуру таблицы после изменений
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- 8. Проверяем уникальность username
SELECT username, COUNT(*) as count
FROM users 
GROUP BY username 
HAVING COUNT(*) > 1;
