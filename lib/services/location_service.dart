import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  bool _isLocationEnabled = false;

  /// Получить текущую позицию пользователя
  Future<Position?> getCurrentLocation() async {
    try {
      // Проверяем, включены ли службы геолокации
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Службы геолокации отключены');
        _isLocationEnabled = false;
        return null;
      }

      // Проверяем разрешения
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Разрешения на геолокацию отклонены');
          _isLocationEnabled = false;
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Разрешения на геолокацию отклонены навсегда');
        _isLocationEnabled = false;
        return null;
      }

      // Получаем текущую позицию
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _isLocationEnabled = true;
      print('Текущая позиция: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
      return _currentPosition;
    } catch (e) {
      print('Ошибка при получении геолокации: $e');
      _isLocationEnabled = false;
      return null;
    }
  }

  /// Вычислить расстояние между двумя точками в километрах
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    try {
      double distanceInMeters = Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
      double distanceInKm = distanceInMeters / 1000;
      return double.parse(distanceInKm.toStringAsFixed(1));
    } catch (e) {
      print('Ошибка при вычислении расстояния: $e');
      return 0.0;
    }
  }

  /// Вычислить расстояние до автошколы
  double? getDistanceToSchool(double? schoolLat, double? schoolLng) {
    if (_currentPosition == null || schoolLat == null || schoolLng == null) {
      return null;
    }

    return calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      schoolLat,
      schoolLng,
    );
  }

  /// Получить адрес по координатам
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street ?? ''}, ${place.locality ?? ''}'.trim();
      }
      return null;
    } catch (e) {
      print('Ошибка при получении адреса: $e');
      return null;
    }
  }

  /// Проверить, включена ли геолокация
  bool get isLocationEnabled => _isLocationEnabled;

  /// Получить текущую позицию (кэшированную)
  Position? get currentPosition => _currentPosition;

  /// Форматировать расстояние для отображения
  String formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).round()} м';
    } else if (distance < 10) {
      return '${distance.toStringAsFixed(1)} км';
    } else {
      return '${distance.round()} км';
    }
  }
}
