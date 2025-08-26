import 'config/cdn_config.dart';

void main() {
  testCloudflareUrls();
  testDifferentUrlVariants();
}

void testCloudflareUrls() {
  print('=== Тест Cloudflare URLs ===');
  
  final testImages = [
    'image001.png',
    'traffic_sign_001',
    'road_situation_002',
  ];
  
  for (final imageName in testImages) {
    print('\nИзображение: $imageName');
    
    // Базовый URL
    final baseUrl = CDNConfig.getImageUrl(imageName);
    print('Базовый URL: $baseUrl');
    
    // Мобильная оптимизация
    final mobileUrl = CDNConfig.getMobileOptimizedUrl(imageName);
    print('Мобильный URL: $mobileUrl');
    
    // Веб оптимизация
    final webUrl = CDNConfig.getWebOptimizedUrl(imageName);
    print('Веб URL: $webUrl');
  }
  
  print('\n=== Проверка структуры URL ===');
  print('Account Hash: 8Bvjq3jb_mpIsntMaLlCpg');
  print('Account ID: dc356eae9b175f6592aacba6e021cb28');
  print('Базовый URL: ${CDNConfig.baseUrl}');
  
  // Проверяем, что URL содержит правильную структуру
  final testUrl = CDNConfig.getImageUrl('test_image');
  if (testUrl.contains('8Bvjq3jb_mpIsntMaLlCpg') && testUrl.contains('/public')) {
    print('✅ URL структура корректна');
  } else {
    print('❌ Ошибка в структуре URL');
  }
}

void testDifferentUrlVariants() {
  print('\n=== Тест разных вариантов URL для image059 ===');
  
  final imageName = 'image059';
  
  // Вариант 1: Без variant
  final url1 = '${CDNConfig.baseUrl}$imageName';
  print('1. Без variant: $url1');
  
  // Вариант 2: С variant public
  final url2 = '${CDNConfig.baseUrl}$imageName/public';
  print('2. С variant public: $url2');
  
  // Вариант 3: С расширением .png
  final url3 = '${CDNConfig.baseUrl}${imageName}.png';
  print('3. С расширением .png: $url3');
  
  // Вариант 4: С расширением и variant
  final url4 = '${CDNConfig.baseUrl}${imageName}.png/public';
  print('4. С расширением и variant: $url4');
  
  // Вариант 5: Только базовый URL
  final url5 = '${CDNConfig.baseUrl}';
  print('5. Базовый URL: $url5');
  
  print('\n=== Инструкция по тестированию ===');
  print('Скопируйте каждый URL и откройте в браузере.');
  print('Тот, который загрузит изображение - правильный!');
}
