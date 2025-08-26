# Настройка базы данных для пользователей

## Создание таблицы users

Выполните следующий SQL запрос в Supabase SQL Editor:

```sql
-- Создание таблицы пользователей
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    email TEXT,
    user_type TEXT NOT NULL CHECK (user_type IN ('student', 'seeker')),
    module_progress JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Создание индексов для оптимизации запросов
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Включение Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Создание политик для доступа к данным
-- Разрешаем всем аутентифицированным пользователям читать данные
CREATE POLICY "Users can view all users" ON users
    FOR SELECT USING (true);

-- Разрешаем всем создавать новых пользователей
CREATE POLICY "Anyone can insert users" ON users
    FOR INSERT WITH CHECK (true);

-- Разрешаем пользователям обновлять только свои данные
CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- Функция для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Триггер для автоматического обновления updated_at
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

## Проверка таблицы

После создания таблицы можно проверить её структуру:

```sql
-- Просмотр структуры таблицы
\d users

-- Проверка данных
SELECT * FROM users LIMIT 5;
```

## Статистика пользователей

Для получения статистики можно использовать следующие запросы:

```sql
-- Общее количество пользователей
SELECT COUNT(*) as total_users FROM users;

-- Количество студентов
SELECT COUNT(*) as students FROM users WHERE user_type = 'student';

-- Количество ищущих автошколу
SELECT COUNT(*) as seekers FROM users WHERE user_type = 'seeker';

-- Статистика по дням регистрации
SELECT 
    DATE(created_at) as registration_date,
    COUNT(*) as new_users,
    COUNT(CASE WHEN user_type = 'student' THEN 1 END) as students,
    COUNT(CASE WHEN user_type = 'seeker' THEN 1 END) as seekers
FROM users 
GROUP BY DATE(created_at)
ORDER BY registration_date DESC;
```

## Настройка API

После создания таблицы API будет автоматически доступен по адресу:
`https://your-project.supabase.co/rest/v1/users`

### Примеры запросов:

1. **Регистрация нового пользователя:**
```bash
POST /rest/v1/users
Content-Type: application/json
apikey: your-anon-key

{
  "name": "Иван Иванов",
  "phone": "+996700123456",
  "user_type": "seeker",
  "email": "ivan@example.com"
}
```

2. **Поиск пользователя по телефону:**
```bash
GET /rest/v1/users?phone=eq.+996700123456
apikey: your-anon-key
```

3. **Получение статистики:**
```bash
GET /rest/v1/users?select=user_type
apikey: your-anon-key
```
