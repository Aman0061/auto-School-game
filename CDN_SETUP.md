# Настройка CDN для изображений

## Обзор

Этот проект использует CDN (Content Delivery Network) для загрузки изображений вместо локального хранения. Это значительно уменьшает размер приложения и улучшает производительность.

## Преимущества использования CDN

- ✅ **Уменьшение размера приложения** - изображения не включаются в APK/IPA
- ✅ **Быстрая загрузка** - изображения загружаются с ближайших серверов
- ✅ **Автоматическое масштабирование** - CDN может оптимизировать размеры
- ✅ **Кэширование** - изображения кэшируются на устройствах
- ✅ **Fallback поддержка** - резервные CDN при недоступности основного

## Настройка CDN

### 1. Обновите конфигурацию

Откройте файл `lib/config/cdn_config.dart` и измените следующие параметры:

```dart
class CDNConfig {
  // Замените на ваш реальный CDN URL
  static const String baseUrl = 'https://your-actual-cdn.com/images/';
  
  // Добавьте резервные CDN если есть
  static const List<String> fallbackUrls = [
    'https://cdn1.your-domain.com/images/',
    'https://cdn2.your-domain.com/images/',
  ];
}
```

### 2. Поддерживаемые CDN сервисы

#### Cloudflare Images
```dart
static const String baseUrl = 'https://imagedelivery.net/your-account-hash/';
// Поддерживает автоматическое масштабирование: ?w=800&h=600&fit=crop
```

#### AWS CloudFront
```dart
static const String baseUrl = 'https://your-distribution.cloudfront.net/images/';
// Поддерживает Lambda@Edge для обработки изображений
```

#### Google Cloud CDN
```dart
static const String baseUrl = 'https://your-bucket.storage.googleapis.com/images/';
// Поддерживает Cloud Storage с CDN
```

#### Imgix
```dart
static const String baseUrl = 'https://your-subdomain.imgix.net/images/';
// Мощный сервис с множеством параметров оптимизации
```

### 3. Структура папок на CDN

Убедитесь, что на вашем CDN изображения организованы следующим образом:

```
https://your-cdn.com/images/
├── image001.jpg
├── image002.jpg
├── image003.jpg
├── ...
└── image404.jpg
```

### 4. Форматы изображений

Поддерживаемые форматы:
- JPG/JPEG (рекомендуется для фотографий)
- PNG (для изображений с прозрачностью)
- WebP (современный формат с лучшим сжатием)

## Использование в коде

### Базовое использование

```dart
import '../services/cdn_service.dart';

// Простое изображение
CDNImage(
  imageName: 'image001',
  width: 400,
  height: 300,
)

// С кастомным placeholder
CDNImage(
  imageName: 'image002',
  placeholder: CircularProgressIndicator(),
  errorWidget: Icon(Icons.error),
)
```

### Оптимизация для разных устройств

```dart
// Для мобильных устройств
CDNImage(
  imageName: 'image003',
  imageName: CDNService.getMobileOptimizedUrl('image003'),
)

// Для веб
CDNImage(
  imageName: CDNService.getWebOptimizedUrl('image003'),
)
```

### С параметрами качества

```dart
// Низкое качество для медленных соединений
CDNImage(
  imageName: CDNService.getImageUrlWithQuality('image004', quality: 60),
)

// Высокое качество для быстрых соединений
CDNImage(
  imageName: CDNService.getImageUrlWithQuality('image004', quality: 95),
)
```

## Настройка кэширования

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (ios/Runner/Info.plist)

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Тестирование

### 1. Проверьте подключение к CDN

```dart
// В консоли разработчика
print('CDN URL: ${CDNService.getImageUrl('image001')}');
```

### 2. Тестирование fallback

```dart
// Проверьте резервные CDN
print('Fallback 1: ${CDNService.getFallbackUrl('image001', 0)}');
print('Fallback 2: ${CDNService.getFallbackUrl('image001', 1)}');
```

### 3. Проверка кэширования

Изображения автоматически кэшируются на устройстве. Проверьте папку кэша:
- Android: `/data/data/your.package/cache/`
- iOS: `/Library/Caches/your.package/`

## Оптимизация производительности

### 1. Предзагрузка изображений

```dart
// Предзагрузите важные изображения
CDNImageWithPreload(
  imageName: 'image001',
  onImageLoaded: () => print('Image loaded!'),
)
```

### 2. Ленивая загрузка

```dart
// Изображения загружаются только при необходимости
ListView.builder(
  itemBuilder: (context, index) {
    return CDNImage(
      imageName: 'image$index',
      placeholder: ShimmerPlaceholder(),
    );
  },
)
```

### 3. Мониторинг производительности

```dart
// Добавьте логирование для отслеживания
CDNImage(
  imageName: 'image001',
  onImageLoaded: () => print('Image loaded successfully'),
  errorWidget: (context, url, error) {
    print('Failed to load image: $error');
    return Icon(Icons.error);
  },
)
```

## Troubleshooting

### Проблема: Изображения не загружаются

**Решение:**
1. Проверьте интернет соединение
2. Убедитесь, что CDN URL правильный
3. Проверьте права доступа к CDN
4. Убедитесь, что изображения существуют на CDN

### Проблема: Медленная загрузка

**Решение:**
1. Используйте CDN с серверами ближе к пользователям
2. Оптимизируйте размеры изображений
3. Используйте WebP формат
4. Включите сжатие на CDN

### Проблема: Ошибки кэширования

**Решение:**
1. Очистите кэш приложения
2. Проверьте права на запись в хранилище
3. Увеличьте размер кэша в настройках

## Заключение

Использование CDN для изображений значительно улучшает производительность приложения и уменьшает его размер. Следуйте инструкциям выше для правильной настройки и оптимизации.

Для дополнительной помощи обратитесь к документации вашего CDN провайдера.
