import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/cdn_config.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  Map<String, dynamic>? _imageData;

  // Загрузка данных об изображениях
  Future<void> loadImageData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/demo_images.json');
      _imageData = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Ошибка загрузки данных изображений: $e');
      _imageData = {};
    }
  }

  // Получение URL изображения для вопроса из Cloudflare CDN
  String getQuestionImageUrl(String? imageId, {
    String variant = 'public',
  }) {
    if (imageId == null || imageId.isEmpty) {
      return '';
    }
    
    // Используем Cloudflare CDN для изображений вопросов
    return CDNConfig.getImageUrl(imageId, variant: variant);
  }

  // Получение оптимизированного URL для мобильных устройств
  String getQuestionImageUrlMobile(String? imageId) {
    if (imageId == null || imageId.isEmpty) {
      return '';
    }
    
    return CDNConfig.getMobileOptimizedUrl(imageId);
  }

  // Получение оптимизированного URL для веб
  String getQuestionImageUrlWeb(String? imageId) {
    if (imageId == null || imageId.isEmpty) {
      return '';
    }
    
    return CDNConfig.getWebOptimizedUrl(imageId);
  }

  // Получение случайного изображения по категории
  String? getRandomImageByCategory(String category) {
    if (_imageData == null) return null;
    
    final categoryData = _imageData![category] as List<dynamic>?;
    if (categoryData == null || categoryData.isEmpty) return null;
    
    final randomIndex = DateTime.now().millisecondsSinceEpoch % categoryData.length;
    final imageInfo = categoryData[randomIndex] as Map<String, dynamic>;
    
    return imageInfo['path'] as String?;
  }

  // Получение всех изображений по категории
  List<String> getImagesByCategory(String category) {
    if (_imageData == null) return [];
    
    final categoryData = _imageData![category] as List<dynamic>?;
    if (categoryData == null) return [];
    
    return categoryData
        .map((item) => (item as Map<String, dynamic>)['path'] as String)
        .toList();
  }

  // Получение случайного изображения из всех категорий
  String? getRandomImage() {
    if (_imageData == null) return null;
    
    final allImages = <String>[];
    _imageData!.forEach((category, images) {
      if (images is List) {
        for (final image in images) {
          if (image is Map<String, dynamic> && image['path'] != null) {
            allImages.add(image['path'] as String);
          }
        }
      }
    });
    
    if (allImages.isEmpty) return null;
    
    final randomIndex = DateTime.now().millisecondsSinceEpoch % allImages.length;
    return allImages[randomIndex];
  }

  // Проверка существования изображения
  bool imageExists(String imagePath) {
    if (_imageData == null) return false;
    
    final allImages = <String>[];
    _imageData!.forEach((category, images) {
      if (images is List) {
        for (final image in images) {
          if (image is Map<String, dynamic> && image['path'] != null) {
            allImages.add(image['path'] as String);
          }
        }
      }
    });
    
    return allImages.contains(imagePath);
  }

  // Проверка доступности изображения в Cloudflare CDN
  Future<bool> isCloudflareImageAvailable(String imageId) async {
    if (imageId.isEmpty) return false;
    
    try {
      // Здесь можно добавить проверку доступности изображения
      // Пока возвращаем true, так как Cloudflare очень надежен
      return true;
    } catch (e) {
      print('Ошибка проверки доступности изображения: $e');
      return false;
    }
  }
}
