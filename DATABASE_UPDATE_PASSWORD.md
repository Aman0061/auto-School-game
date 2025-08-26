-- Обновление таблицы users для добавления поля password
-- Выполните этот скрипт в Supabase SQL Editor

-- Добавляем поле password в таблицу users
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS password TEXT;

-- Обновляем существующие записи, устанавливая временный пароль
UPDATE users 
SET password = 'default_password_' || id 
WHERE password IS NULL;

-- Создаем индекс для оптимизации поиска по паролю (опционально)
CREATE INDEX IF NOT EXISTS idx_users_password ON users(password);

-- Проверяем структуру таблицы
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- Пример запроса для проверки данных
SELECT id, name, email, phone, user_type, password IS NOT NULL as has_password, created_at 
FROM users 
LIMIT 5;
