#!/usr/bin/env python3
"""
Простой скрипт для обновления JSON файла с вопросами:
заменяет имена файлов на Image ID из Cloudflare
"""

import json
import urllib.request
import urllib.parse

# Конфигурация Cloudflare
ACCOUNT_ID = "dc356eae9b175f6592aacba6e021cb28"
API_TOKEN = "LUJU1UKz9EaukbqW2xKqHaTKb9pYBCAZK2VeUrEU"

def get_all_cloudflare_images():
    """Получает ВСЕ изображения из Cloudflare за один запрос"""
    print("🔄 Получение всех изображений...")
    
    # Запрашиваем все изображения сразу с большим per_page
    url = f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT_ID}/images/v1?page=1&per_page=1000"
    
    print(f"📄 Загружаю все изображения за один запрос...")
    
    # Создаем запрос с заголовками
    req = urllib.request.Request(url)
    req.add_header("Authorization", f"Bearer {API_TOKEN}")
    
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            
            if data.get("success"):
                images = data["result"]["images"]
                print(f"📸 Получено {len(images)} изображений")
                return images
            else:
                print(f"❌ Ошибка API: {data.get('errors', [])}")
                return []
    except Exception as e:
        print(f"❌ Ошибка получения изображений: {e}")
        return []

def create_image_mapping(images):
    """Создает маппинг имени файла на Image ID"""
    mapping = {}
    print(f"\n🔗 Создание маппинга для {len(images)} изображений...")
    
    for img in images:
        filename = img["filename"]
        image_id = img["id"]
        mapping[filename] = image_id
        print(f"  {filename} -> {image_id}")
    
    return mapping

def update_questions_json(mapping):
    """Обновляет JSON файл с вопросами"""
    try:
        print(f"\n📝 Обновление JSON файла...")
        
        # Читаем JSON файл
        with open("assets/data/questions.json", "r", encoding="utf-8") as f:
            questions = json.load(f)
        
        updated_count = 0
        not_found_count = 0
        
        # Обновляем вопросы
        for question in questions:
            if "image" in question and question["image"]:
                old_image = question["image"]
                if old_image in mapping:
                    question["image"] = mapping[old_image]
                    updated_count += 1
                    print(f"✅ Обновлен: {old_image} -> {mapping[old_image]}")
                else:
                    not_found_count += 1
                    print(f"❌ Не найден Image ID для: {old_image}")
        
        # Сохраняем обновленный файл
        with open("assets/data/questions_updated.json", "w", encoding="utf-8") as f:
            json.dump(questions, f, ensure_ascii=False, indent=2)
        
        print(f"\n📊 Статистика:")
        print(f"✅ Обновлено: {updated_count} вопросов")
        print(f"❌ Не найдено: {not_found_count} изображений")
        print(f"📁 Файл сохранен как: assets/data/questions_updated.json")
        
    except Exception as e:
        print(f"❌ Ошибка обновления JSON: {e}")

def main():
    print("🚀 Запуск обновления Cloudflare Images")
    print("=" * 50)
    
    images = get_all_cloudflare_images()
    
    if not images:
        print("❌ Не удалось получить изображения")
        return
    
    print(f"\n📸 Всего найдено {len(images)} изображений")
    
    mapping = create_image_mapping(images)
    
    update_questions_json(mapping)
    
    print("\n🎉 Готово! Теперь замените questions.json на questions_updated.json")

if __name__ == "__main__":
    main()
