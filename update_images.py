#!/usr/bin/env python3
"""
Скрипт для обновления JSON файла с вопросами:
заменяет имена файлов на Image ID из Cloudflare
"""

import json
import requests

# Конфигурация Cloudflare
ACCOUNT_ID = "dc356eae9b175f6592aacba6e021cb28"
API_TOKEN = "LUJU1UKz9EaukbqW2xKqHaTKb9pYBCAZK2VeUrEU"

def get_cloudflare_images():
    """Получает список изображений из Cloudflare"""
    url = f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT_ID}/images/v1?page=1&per_page=100"
    headers = {"Authorization": f"Bearer {API_TOKEN}"}
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = response.json()
        
        if data.get("success"):
            return data["result"]["images"]
        else:
            print(f"Ошибка API: {data.get('errors', [])}")
            return []
    except Exception as e:
        print(f"Ошибка получения изображений: {e}")
        return []

def create_image_mapping(images):
    """Создает маппинг имени файла на Image ID"""
    mapping = {}
    for img in images:
        filename = img["filename"]
        image_id = img["id"]
        mapping[filename] = image_id
        print(f"{filename} -> {image_id}")
    return mapping

def update_questions_json(mapping):
    """Обновляет JSON файл с вопросами"""
    try:
        # Читаем JSON файл
        with open("assets/data/questions.json", "r", encoding="utf-8") as f:
            questions = json.load(f)
        
        updated_count = 0
        
        # Обновляем вопросы
        for question in questions:
            if "image" in question and question["image"]:
                old_image = question["image"]
                if old_image in mapping:
                    question["image"] = mapping[old_image]
                    updated_count += 1
                    print(f"Обновлен: {old_image} -> {mapping[old_image]}")
                else:
                    print(f"Не найден Image ID для: {old_image}")
        
        # Сохраняем обновленный файл
        with open("assets/data/questions_updated.json", "w", encoding="utf-8") as f:
            json.dump(questions, f, ensure_ascii=False, indent=2)
        
        print(f"\n✅ Обновлено {updated_count} вопросов")
        print("Файл сохранен как: assets/data/questions_updated.json")
        
    except Exception as e:
        print(f"Ошибка обновления JSON: {e}")

def main():
    print("🔄 Получение изображений из Cloudflare...")
    images = get_cloudflare_images()
    
    if not images:
        print("❌ Не удалось получить изображения")
        return
    
    print(f"📸 Найдено {len(images)} изображений")
    
    print("\n🔗 Создание маппинга...")
    mapping = create_image_mapping(images)
    
    print(f"\n📝 Обновление JSON файла...")
    update_questions_json(mapping)
    
    print("\n🎉 Готово! Теперь замените questions.json на questions_updated.json")

if __name__ == "__main__":
    main()
