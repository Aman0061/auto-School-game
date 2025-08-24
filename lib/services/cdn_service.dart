import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/cdn_config.dart';

class CDNService {
  // Получить полный URL изображения
  static String getImageUrl(String imageName) {
    return CDNConfig.getImageUrl(imageName);
  }
  
  // Получить URL изображения с определенным размером
  static String getImageUrlWithSize(String imageName, {int width = 400, int height = 300}) {
    return CDNConfig.getImageUrl(imageName, width: width, height: height);
  }
  
  // Получить URL изображения с качеством
  static String getImageUrlWithQuality(String imageName, {int quality = 80}) {
    return CDNConfig.getImageUrl(imageName, quality: quality);
  }
  
  // Получить URL изображения с оптимизацией для мобильных устройств
  static String getMobileOptimizedUrl(String imageName) {
    return CDNConfig.getMobileUrl(imageName);
  }
  
  // Получить URL изображения с оптимизацией для веб
  static String getWebOptimizedUrl(String imageName) {
    return CDNConfig.getWebUrl(imageName);
  }
  
  // Получить fallback URL
  static String getFallbackUrl(String imageName, int fallbackIndex) {
    return CDNConfig.getFallbackUrl(imageName, fallbackIndex);
  }
}

// Виджет для отображения изображений из CDN с кэшированием
class CDNImage extends StatelessWidget {
  final String imageName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final BoxShadow? boxShadow;

  const CDNImage({
    super.key,
    required this.imageName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = CDNService.getImageUrl(imageName);
    
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
      cacheKey: imageName,
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
  final String imageName;
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
    required this.imageName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
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
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return CDNImage(
      imageName: widget.imageName,
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
