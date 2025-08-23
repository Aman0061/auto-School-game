import 'package:json_annotation/json_annotation.dart';

part 'driving_school.g.dart';

@JsonSerializable()
class DrivingSchool {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final String? imagePath;
  final String address;
  final String phone;
  final List<String> features; // особенности школы
  final String category; // категория прав

  DrivingSchool({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.imagePath,
    required this.address,
    required this.phone,
    required this.features,
    required this.category,
  });

  factory DrivingSchool.fromJson(Map<String, dynamic> json) => _$DrivingSchoolFromJson(json);
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
