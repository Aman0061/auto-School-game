// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driving_school.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrivingSchool _$DrivingSchoolFromJson(Map<String, dynamic> json) =>
    DrivingSchool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      imagePath: json['imagePath'] as String?,
      address: json['address'] as String,
      phone: json['phone'] as String,
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      category: json['category'] as String,
    );

Map<String, dynamic> _$DrivingSchoolToJson(DrivingSchool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'imagePath': instance.imagePath,
      'address': instance.address,
      'phone': instance.phone,
      'features': instance.features,
      'category': instance.category,
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
