import 'package:json_annotation/json_annotation.dart';
import 'dart:math' as math;

part 'driving_school.g.dart';

@JsonSerializable()
class LicenseCategory {
  @JsonKey(name: 'id')
  final int id;
  
  @JsonKey(name: 'code')
  final String code;
  
  @JsonKey(name: 'name')
  final String name;
  
  @JsonKey(name: 'description')
  final String? description;

  LicenseCategory({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  factory LicenseCategory.fromJson(Map<String, dynamic> json) => _$LicenseCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$LicenseCategoryToJson(this);
}

@JsonSerializable()
class SchoolPrice {
  @JsonKey(name: 'id')
  final int id;
  
  @JsonKey(name: 'school_id')
  final String? schoolId;
  
  @JsonKey(name: 'category_id')
  final int? categoryId;
  
  @JsonKey(name: 'price')
  final int price;
  
  @JsonKey(name: 'currency')
  final String currency;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  SchoolPrice({
    required this.id,
    this.schoolId,
    this.categoryId,
    required this.price,
    this.currency = 'RUB',
    this.isActive = true,
    this.createdAt,
  });

  factory SchoolPrice.fromJson(Map<String, dynamic> json) => _$SchoolPriceFromJson(json);
  Map<String, dynamic> toJson() => _$SchoolPriceToJson(this);
}

@JsonSerializable()
class DrivingSchool {
  @JsonKey(name: 'id')
  final String id;
  
  @JsonKey(name: 'name')
  final String name;
  
  @JsonKey(name: 'city')
  final String city;
  
  @JsonKey(name: 'address')
  final String address;
  
  @JsonKey(name: 'phone')
  final String phone;
  
  @JsonKey(name: 'categories')
  final List<String> categories;
  
  @JsonKey(name: 'price_from')
  final int priceFrom;
  
  @JsonKey(name: 'rating')
  final double? rating;
  
  @JsonKey(name: 'reviews_count')
  final int reviewsCount;
  
  @JsonKey(name: 'lat')
  final double? lat;
  
  @JsonKey(name: 'lng')
  final double? lng;
  
  @JsonKey(name: 'description')
  final String? description;
  
  @JsonKey(name: 'site')
  final String? site;
  
  @JsonKey(name: 'whatsapp')
  final String? whatsapp;
  
  @JsonKey(name: 'telegram')
  final String? telegram;
  
  @JsonKey(name: 'logo_cdn')
  final String? logoCdn;
  
  @JsonKey(name: 'payed')
  final bool payed; // "Рекомендовано" - соответствует isPromoted
  
  @JsonKey(name: 'approved')
  final bool approved;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  DrivingSchool({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    required this.categories,
    required this.priceFrom,
    this.rating,
    this.reviewsCount = 0,
    this.lat,
    this.lng,
    this.description,
    this.site,
    this.whatsapp,
    this.telegram,
    this.logoCdn,
    required this.payed,
    this.approved = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Геттер для обратной совместимости
  bool get isPromoted => payed;
  
  // Геттер для цены (обратная совместимость)
  double get price => priceFrom.toDouble();
  
  // Геттер для количества отзывов (обратная совместимость)
  int get reviewCount => reviewsCount;
  
  // Геттер для описания (обратная совместимость)
  String get descriptionText => description ?? 'Описание не указано';
  
  // Геттер для особенностей (используем категории)
  List<String> get features => categories;

  /// Вычислить расстояние до автошколы
  double? getDistanceToUser(double? userLat, double? userLng) {
    if (lat == null || lng == null || userLat == null || userLng == null) {
      return null;
    }

    // Простая формула гаверсинуса для вычисления расстояния
    const double earthRadius = 6371; // Радиус Земли в километрах
    
    double lat1 = userLat * (math.pi / 180);
    double lat2 = lat! * (math.pi / 180);
    double deltaLat = (lat! - userLat) * (math.pi / 180);
    double deltaLng = (lng! - userLng) * (math.pi / 180);

    double a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
               math.cos(lat1) * math.cos(lat2) * math.sin(deltaLng / 2) * math.sin(deltaLng / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    double distance = earthRadius * c;
    return double.parse(distance.toStringAsFixed(1));
  }

  /// Форматировать расстояние для отображения
  String formatDistance(double? userLat, double? userLng) {
    double? distance = getDistanceToUser(userLat, userLng);
    if (distance == null) return '';

    if (distance < 1) {
      return '${(distance * 1000).round()} м';
    } else if (distance < 10) {
      return '${distance.toStringAsFixed(1)} км';
    } else {
      return '${distance.round()} км';
    }
  }

  factory DrivingSchool.fromJson(Map<String, dynamic> json) {
    // Отладочная информация для проверки парсинга
    if (json['name'] == 'ильяз') {
      print('!!! ПАРСИНГ АВТОШКОЛЫ ИЛЬЯЗ !!!');
      print('Сырые данные: ${json.toString()}');
      print('Поле payed в JSON: ${json['payed']}');
      print('Тип поля payed в JSON: ${json['payed'].runtimeType}');
    }
    
    return _$DrivingSchoolFromJson(json);
  }
  Map<String, dynamic> toJson() => _$DrivingSchoolToJson(this);
}

@JsonSerializable()
class Review {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
