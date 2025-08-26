// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driving_school.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LicenseCategory _$LicenseCategoryFromJson(Map<String, dynamic> json) =>
    LicenseCategory(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$LicenseCategoryToJson(LicenseCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
    };

SchoolPrice _$SchoolPriceFromJson(Map<String, dynamic> json) => SchoolPrice(
  id: (json['id'] as num).toInt(),
  schoolId: json['school_id'] as String?,
  categoryId: (json['category_id'] as num?)?.toInt(),
  price: (json['price'] as num).toInt(),
  currency: json['currency'] as String? ?? 'RUB',
  isActive: json['is_active'] as bool? ?? true,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SchoolPriceToJson(SchoolPrice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'school_id': instance.schoolId,
      'category_id': instance.categoryId,
      'price': instance.price,
      'currency': instance.currency,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
    };

DrivingSchool _$DrivingSchoolFromJson(Map<String, dynamic> json) =>
    DrivingSchool(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      categories:
          (json['categories'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      priceFrom: (json['price_from'] as num).toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      description: json['description'] as String?,
      site: json['site'] as String?,
      whatsapp: json['whatsapp'] as String?,
      telegram: json['telegram'] as String?,
      logoCdn: json['logo_cdn'] as String?,
      payed: json['payed'] as bool,
      approved: json['approved'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$DrivingSchoolToJson(DrivingSchool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'city': instance.city,
      'address': instance.address,
      'phone': instance.phone,
      'categories': instance.categories,
      'price_from': instance.priceFrom,
      'rating': instance.rating,
      'reviews_count': instance.reviewsCount,
      'lat': instance.lat,
      'lng': instance.lng,
      'description': instance.description,
      'site': instance.site,
      'whatsapp': instance.whatsapp,
      'telegram': instance.telegram,
      'logo_cdn': instance.logoCdn,
      'payed': instance.payed,
      'approved': instance.approved,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: json['id'] as String,
  userName: json['userName'] as String,
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'userName': instance.userName,
  'rating': instance.rating,
  'comment': instance.comment,
  'date': instance.date.toIso8601String(),
};
