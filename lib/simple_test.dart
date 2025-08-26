import 'config/cdn_config.dart';

void main() {
  print('=== Тест Cloudflare URL с Image ID ===');
  
  final accountHash = '8Bvjq3jb_mpIsntMaLlCpg';
  final accountId = 'dc356eae9b175f6592aacba6e021cb28';
  
  print('Account Hash: $accountHash');
  print('Account ID: $accountId');
  
  // Базовый URL
  final baseUrl = 'https://imagedelivery.net/$accountHash/';
  print('\nБазовый URL: $baseUrl');
  
  // Правильные Image ID из Cloudflare
  final testImageIds = [
    '6ab61c76-25d3-40ae-bf27-1b502634d900', // image059.png
    '7684cdf4-126b-41b5-0cc1-8f9acccc8b00', // image058.png
    '82a2206e-90e5-4a3d-5d77-b04313ea4b00', // image065.png
  ];
  
  print('\n=== Тестовые URL с Image ID ===');
  for (int i = 0; i < testImageIds.length; i++) {
    final imageId = testImageIds[i];
    final url = '$baseUrl$imageId/public';
    print('${i + 1}. $url');
  }
  
  print('\n=== Тест через CDNConfig ===');
  final simpleUrl = CDNConfig.getSimpleUrl('6ab61c76-25d3-40ae-bf27-1b502634d900');
  print('CDNConfig URL: $simpleUrl');
  
  final mobileUrl = CDNConfig.getMobileOptimizedUrl('6ab61c76-25d3-40ae-bf27-1b502634d900');
  print('Мобильный URL: $mobileUrl');
  
  print('\n=== Инструкция ===');
  print('1. Скопируйте любой из тестовых URL и откройте в браузере');
  print('2. Если изображение загружается - значит все работает!');
  print('3. Теперь нужно обновить JSON файл с Image ID вместо имен файлов');
}
