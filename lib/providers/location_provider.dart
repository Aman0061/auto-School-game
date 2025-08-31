import 'package:flutter/foundation.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  double? _userLat;
  double? _userLng;
  bool _isLoading = false;
  String? _error;

  // Геттеры
  double? get userLat => _userLat;
  double? get userLng => _userLng;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLocationEnabled => _locationService.isLocationEnabled;

  /// Инициализация геолокации
  Future<void> initializeLocation() async {
    if (_userLat != null && _userLng != null) {
      return; // Геолокация уже инициализирована
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _userLat = position.latitude;
        _userLng = position.longitude;
        print('Геолокация инициализирована: $_userLat, $_userLng');
      } else {
        _error = 'Не удалось получить геолокацию';
      }
    } catch (e) {
      _error = 'Ошибка при получении геолокации: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Обновить геолокацию
  Future<void> refreshLocation() async {
    _userLat = null;
    _userLng = null;
    await initializeLocation();
  }

  /// Получить расстояние до точки
  double? getDistanceTo(double? targetLat, double? targetLng) {
    if (_userLat == null || _userLng == null || targetLat == null || targetLng == null) {
      return null;
    }

    return _locationService.calculateDistance(
      _userLat!,
      _userLng!,
      targetLat,
      targetLng,
    );
  }

  /// Форматировать расстояние для отображения
  String formatDistance(double? targetLat, double? targetLng) {
    double? distance = getDistanceTo(targetLat, targetLng);
    if (distance == null) return '';

    return _locationService.formatDistance(distance);
  }

  /// Очистить ошибку
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
