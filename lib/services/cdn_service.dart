import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/cdn_config.dart';
import 'image_service.dart';

class CDNService {
  // Получить полный URL изображения
  static String getImageUrl(String imageId) {
    return CDNConfig.getImageUrl(imageId);
  }
  
  // Получить URL изображения с определенным размером
  static String getImageUrlWithSize(String imageId, {int width = 400, int height = 300}) {
    return CDNConfig.getImageUrl(imageId);
  }
  
  // Получить URL изображения с качеством
  static String getImageUrlWithQuality(String imageId, {int quality = 80}) {
    return CDNConfig.getImageUrl(imageId);
  }
  
  // Получить URL изображения с оптимизацией для мобильных устройств
  static String getMobileOptimizedUrl(String imageId) {
    return CDNConfig.getMobileOptimizedUrl(imageId);
  }
  
  // Получить URL изображения с оптимизацией для веб
  static String getWebOptimizedUrl(String imageId) {
    return CDNConfig.getWebOptimizedUrl(imageId);
  }
  
  // Получить fallback URL
  static String getFallbackUrl(String imageId, int fallbackIndex) {
    return CDNConfig.getFallbackUrl(imageId, fallbackIndex);
  }
  
  // Специальные методы для Cloudflare Images
  
  // Получить URL с автоматическим форматом
  static String getAutoFormatUrl(String imageId, {
    int? width,
    int? height,
    int? quality,
    String fit = 'crop',
  }) {
    return CDNConfig.getSimpleUrl(imageId);
  }
  
  // Получить URL с определенным форматом
  static String getFormatUrl(String imageId, String format, {
    int? width,
    int? height,
    int? quality,
    String fit = 'crop',
  }) {
    return CDNConfig.getFormatUrl(imageId, format);
  }
  
  // Получить URL с оптимизацией для Retina дисплеев
  static String getRetinaUrl(String imageId, {
    int? width,
    int? height,
    int? quality,
    String fit = 'crop',
  }) {
    // Для Retina дисплеев увеличиваем размер в 2 раза
    final retinaWidth = width != null ? width * 2 : null;
    final retinaHeight = height != null ? height * 2 : null;
    
    return CDNConfig.getSimpleUrl(imageId);
  }
}

// Виджет для отображения изображений из CDN с кэшированием
class CDNImage extends StatelessWidget {
  final String imageId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final BoxShadow? boxShadow;
  final bool useMobileOptimization;

  const CDNImage({
    super.key,
    required this.imageId,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.boxShadow,
    this.useMobileOptimization = true,
  });

  @override
  Widget build(BuildContext context) {
    // Используем ImageService для получения URL из Cloudflare CDN
    final imageService = ImageService();
    final imageUrl = useMobileOptimization 
        ? imageService.getQuestionImageUrlMobile(imageId)
        : imageService.getQuestionImageUrl(imageId);
    
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      // Настройки кэширования
      cacheKey: imageId,
      maxWidthDiskCache: 1200,
      maxHeightDiskCache: 900,
      memCacheWidth: 800,
      memCacheHeight: 600,
    );

    // Применяем декорации если указаны
    if (borderRadius != null || boxShadow != null) {
      imageWidget = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: boxShadow != null ? [boxShadow!] : null,
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: imageWidget,
        ),
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Загрузка...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Изображение не найдено',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Виджет для отображения изображений с предзагрузкой
class CDNImageWithPreload extends StatefulWidget {
  final String imageId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final BoxShadow? boxShadow;
  final VoidCallback? onImageLoaded;

  const CDNImageWithPreload({
    super.key,
    required this.imageId,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.boxShadow,
    this.onImageLoaded,
  });

  @override
  State<CDNImageWithPreload> createState() => _CDNImageWithPreloadState();
}

class _CDNImageWithPreloadState extends State<CDNImageWithPreload> {
  // Убираем неиспользуемое поле
  // bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return CDNImage(
      imageId: widget.imageId,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
      borderRadius: widget.borderRadius,
      boxShadow: widget.boxShadow,
    );
  }
}
