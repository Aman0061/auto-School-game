-- SQL скрипт для просмотра структуры таблицы users
-- Используется для Supabase (PostgreSQL)

-- Вариант 1: Показать все поля таблицы users с типами данных
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'users' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- Вариант 2: Более детальная информация о таблице
SELECT 
    c.column_name,
    c.data_type,
    c.is_nullable,
    c.column_default,
    c.character_maximum_length,
    c.numeric_precision,
    c.numeric_scale,
    pgd.description as column_comment
FROM information_schema.columns c
LEFT JOIN pg_catalog.pg_statio_all_tables st 
    ON (c.table_schema = st.schemaname AND c.table_name = st.relname)
LEFT JOIN pg_catalog.pg_description pgd 
    ON (pgd.objoid = st.relid AND pgd.objsubid = c.ordinal_position)
WHERE c.table_name = 'users' 
    AND c.table_schema = 'public'
ORDER BY c.ordinal_position;

-- Вариант 3: Простой просмотр структуры (только названия полей)
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'users' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- Вариант 4: Показать индексы таблицы users
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'users';

-- Вариант 5: Показать ограничения таблицы users
SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = (
    SELECT oid 
    FROM pg_class 
    WHERE relname = 'users'
    LIMIT 1
);

-- Вариант 6: Альтернативный способ просмотра ограничений (более безопасный)
SELECT 
    tc.constraint_name,
    tc.constraint_type,
    tc.table_name,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'users' 
    AND tc.table_schema = 'public';
