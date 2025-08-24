class CDNConfig {
  // Основной URL вашего CDN
  static const String baseUrl = 'https://your-cdn-domain.com/images/';
  
  // Альтернативные CDN (для fallback)
  static const List<String> fallbackUrls = [
    'https://cdn1.your-domain.com/images/',
    'https://cdn2.your-domain.com/images/',
  ];
  
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
  
  // Получить URL изображения с параметрами
  static String getImageUrl(String imageName, {
    int? width,
    int? height,
    int? quality,
    String format = 'jpg',
  }) {
    if (imageName.isEmpty) return '';
    
    // Убираем расширение файла если оно есть
    String cleanName = imageName;
    if (cleanName.contains('.')) {
      cleanName = cleanName.split('.').first;
    }
    
    // Формируем базовый URL
    String url = '$baseUrl$cleanName.$format';
    
    // Добавляем параметры если указаны
    List<String> params = [];
    
    if (width != null) params.add('w=$width');
    if (height != null) params.add('h=$height');
    if (quality != null) params.add('q=$quality');
    
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    
    return url;
  }
  
  // Получить URL для мобильных устройств
  static String getMobileUrl(String imageName) {
    final sizes = imageSizes['mobile']!;
    return getImageUrl(
      imageName,
      width: sizes['width'],
      height: sizes['height'],
      quality: qualitySettings['normal'],
    );
  }
  
  // Получить URL для веб
  static String getWebUrl(String imageName) {
    final sizes = imageSizes['desktop']!;
    return getImageUrl(
      imageName,
      width: sizes['width'],
      height: sizes['height'],
      quality: qualitySettings['fast'],
    );
  }
  
  // Получить fallback URL если основной недоступен
  static String getFallbackUrl(String imageName, int fallbackIndex) {
    if (fallbackIndex >= fallbackUrls.length) return '';
    
    final fallbackBase = fallbackUrls[fallbackIndex];
    String cleanName = imageName;
    if (cleanName.contains('.')) {
      cleanName = cleanName.split('.').first;
    }
    
    return '$fallbackBase$cleanName.jpg';
  }
}
