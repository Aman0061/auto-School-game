// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  userType: json['userType'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  moduleProgress: Map<String, int>.from(json['moduleProgress'] as Map),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'phone': instance.phone,
  'userType': instance.userType,
  'createdAt': instance.createdAt.toIso8601String(),
  'moduleProgress': instance.moduleProgress,
};
