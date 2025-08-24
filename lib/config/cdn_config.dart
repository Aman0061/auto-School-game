class CDNConfig {
  // Основной URL для Cloudflare Images
  // Account Hash: 8Bvjq3jb_mpIsntMaLlCpg
  // Account ID: dc356eae9b175f6592aacba6e021cb28
  static const String baseUrl = 'https://imagedelivery.net/8Bvjq3jb_mpIsntMaLlCpg/';
  
  // Cloudflare Images поддерживает автоматическое масштабирование
  // Fallback не нужен, так как Cloudflare очень надежен
  static const List<String> fallbackUrls = [];
  
  // Поддерживаемые форматы изображений
  static const List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Размеры изображений для разных устройств
  static const Map<String, Map<String, int>> imageSizes = {
    'mobile': {
      'width': 800,
      'height': 600,
    },
    'tablet': {
      'width': 1200,
      'height': 900,
    },
    'desktop': {
      'width': 1600,
      'height': 1200,
    },
  };
  
  // Качество изображений для разных соединений
  static const Map<String, int> qualitySettings = {
    'slow': 60,    // Медленное соединение
    'normal': 80,  // Обычное соединение
    'fast': 95,    // Быстрое соединение
  };
  
  // Таймауты для загрузки
  static const Map<String, Duration> timeouts = {
    'connection': Duration(seconds: 10),
    'receive': Duration(seconds: 30),
    'send': Duration(seconds: 10),
  };
  
  // Настройки кэширования
  static const Map<String, dynamic> cacheSettings = {
    'maxAge': Duration(days: 7),
    'maxSize': 100 * 1024 * 1024, // 100 MB
    'priority': 1,
  };
  
  // Получить URL изображения по Image ID для Cloudflare Images
  static String getImageUrl(String imageId, {
    String variant = 'public',
  }) {
    if (imageId.isEmpty) return '';
    
    // Убираем расширение файла если оно есть (для обратной совместимости)
    String cleanId = imageId;
    if (cleanId.contains('.')) {
      cleanId = imageId.split('.').first;
    }
    
    // Формируем URL для Cloudflare Images с Image ID
    return '$baseUrl$cleanId/$variant';
  }
  
  // Получить URL для мобильных устройств
  static String getMobileUrl(String imageId) {
    return getImageUrl(imageId, variant: 'public');
  }
  
  // Получить URL для веб
  static String getWebUrl(String imageId) {
    return getImageUrl(imageId, variant: 'public');
  }
  
  // Получить fallback URL если основной недоступен
  static String getFallbackUrl(String imageId, int fallbackIndex) {
    if (fallbackIndex >= fallbackUrls.length) return '';
    
    final fallbackBase = fallbackUrls[fallbackIndex];
    String cleanId = imageId;
    if (cleanId.contains('.')) {
      cleanId = imageId.split('.').first;
    }
    
    return '$fallbackBase$cleanId.jpg';
  }
  
  // Специальные методы для Cloudflare Images
  
  // Получить простой URL по Image ID
  static String getSimpleUrl(String imageId, {
    String variant = 'public',
  }) {
    if (imageId.isEmpty) return '';
    
    String cleanId = imageId;
    if (cleanId.contains('.')) {
      cleanId = imageId.split('.').first;
    }
    
    return '$baseUrl$cleanId/$variant';
  }
  
  // Получить URL с определенным форматом
  static String getFormatUrl(String imageId, String format, {
    String variant = 'public',
  }) {
    if (imageId.isEmpty) return '';
    
    String cleanId = imageId;
    if (cleanId.contains('.')) {
      cleanId = imageId.split('.').first;
    }
    
    return '$baseUrl$cleanId/$variant';
  }
  
  // Получить URL с оптимизацией для мобильных устройств
  static String getMobileOptimizedUrl(String imageId) {
    return getSimpleUrl(imageId, variant: 'public');
  }
  
  // Получить URL с оптимизацией для веб
  static String getWebOptimizedUrl(String imageId) {
    return getSimpleUrl(imageId, variant: 'public');
  }
}
